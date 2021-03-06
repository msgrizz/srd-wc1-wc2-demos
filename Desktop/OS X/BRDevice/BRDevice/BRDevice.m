//
//  BRDevice.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfiguration.h"
#import "PLTDLog.h"
#import "BRDevice.h"
#import "BRDevice_Private.h"
#import "BRDeviceWatcher.h"
#import "BRRemoteDevice.h"
#import "BRRemoteDevice_Private.h"
#import "BRMessage.h"
#import "BRMessage_Private.h"
#import	"BRIncomingMessage.h"
#import "BRIncomingMessage_Private.h"
#import "BROutgoingMessage.h"
#import "BROutgoingMessage_Private.h"
#import "BRCommandResult.h"
#import "BRSettingResult.h"
#import "BREvent.h"
#import "BRException.h"
#import "BRHostVersionNegotiateMessage.h"
#import "BRDeviceProtocolVersionMessage.h"
#import "BRMetadataMessage.h"
#import "BRCloseSessionMessage.h"
#import "BRIncomingMessageDecoder.h"
#import "BRDeviceUtilities.h"

#import "BRConnectedDeviceEvent.h"
#import "BRDisconnectedDeviceEvent.h"

#ifdef BANGLE
#import "BRApplicationActionResultEvent.h"
#endif

#ifdef TARGET_OSX
#import <IOBluetooth/Bluetooth.h>
#import <IOBluetooth/IOBluetoothUserLib.h>
#import <IOBluetooth/IOBluetooth.h>
#endif
#ifdef TARGET_IOS
#import <ExternalAccessory/ExternalAccessory.h>
#endif

#ifdef GENESIS
#import "BRRawMessage.h"
#endif


//#define MESSAGE_DELAY				300 // ms
#define DISCONNECT_DELAY			250 // ms
#define PENDING_MESSAGE_TIMEOUT		900 // ms -- poll time is 300, may take two polls = 600ms + BT overhead


#ifdef TARGET_IOS
NSString *const BRDeviceEAProtocolString =							@"com.plantronics.headsetdataservice";
NSString *const BRDeviceErrorDomain =								@"com.plantronics.BRDevice";
#endif


NSString *const BRDeviceDidAppearNotification =						@"BRDeviceDidAppearNotification";
NSString *const BRDeviceDidDisappearNotification =					@"BRDeviceDidDisappearNotification";
NSString *const BRDeviceNotificationKey =							@"BRDeviceNotificationKey";


#ifdef TARGET_OSX
@interface BRDevice ()
#endif
#ifdef TARGET_IOS
@interface BRDevice () <EAAccessoryDelegate, NSStreamDelegate>
#endif

- (void)dispatchNextOutgoingMessage;
- (void)_sendMessage:(BRMessage *)message;
- (void)checkInputBuffer;
#ifdef TARGET_IOS
- (void)checkOutputBuffers;
#endif
- (void)parseIncomingMessage:(NSData *)data;
- (void)checkAndDispatchNextOutgoingMessage:(BRIncomingMessage *)incomingMessage;
- (void)startCloseSessionTimer;
- (void)cancelCloseSessionTimer;
- (void)closeSessionTimer:(NSTimer *)aTimer;
- (void)startPendingMessageTimer;
- (void)stopPendingMessageTimer;
- (void)pendingMessageTimer:(NSTimer *)aTimer;
//#ifdef DELAY_MESSAGES
//- (void)checkSendMessage:(NSTimer *)aTimer;
//#endif

@property(nonatomic,strong)				NSMutableData				*inputBuffer;
@property(nonatomic,strong,readwrite)	NSMutableDictionary			*remoteDevices;
@property(nonatomic,strong)				NSTimer						*closeSessionTimer;
#ifdef TARGET_OSX
@property(nonatomic,strong)             IOBluetoothRFCOMMChannel    *RFCOMMChannel;
#endif
#ifdef TARGET_IOS
@property(nonatomic,strong)				EASession					*session;
@property(nonatomic,assign)             BOOL                        streamOpened;
@property(nonatomic,strong)				NSMutableArray				*outputBuffers;
#endif
@property(nonatomic,strong)				NSMutableArray				*outgoingMessageQueue;
@property(nonatomic,strong)				BROutgoingMessage			*pendingOutgoingMessage;
@property(nonatomic,strong)				NSTimer						*pendingMessageTimer;
//#ifdef DELAY_MESSAGES
//@property(nonatomic,strong)				NSMutableArray				*outputMessageQueue;
//@property(nonatomic,strong)				NSDate						*lastMessageSendDate;
//@property(nonatomic,strong)				NSTimer						*checkSendMessageTimer;
//#endif

@end


@implementation BRDevice

@dynamic isConnected;

- (BOOL)isConnected
{
	return self.state == BRDeviceStateConnected;
}

#pragma mark - Public

+ (NSArray *)availableDevices
{
	[PLTDLogger sharedLogger];
	
	return [[BRDeviceWatcher sharedWatcher] devices];
}

#ifdef TARGET_OSX
+ (BRDevice *)deviceWithAddress:(NSString *)bluetoothAddress
{
	[PLTDLogger sharedLogger];
	
    BRDevice *device = [[BRDevice alloc] init];
    device.bluetoothAddress = bluetoothAddress;
    return device;
}
#endif

#ifdef TARGET_IOS
+ (BRDevice *)deviceWithAccessory:(EAAccessory *)anAccessory
{
	[PLTDLogger sharedLogger];
	
    BRDevice *device = [[BRDevice alloc] init];
    device.accessory = anAccessory;
    return device;
}
#endif

- (void)openConnection
{
#ifdef TARGET_OSX
	DLog(DLogLevelInfo, @"Opening connection to device at address %@...", self.bluetoothAddress);
	
	if (!self.isConnected) {
		self.state = BRDeviceStateOpeningLink;
		self.remoteDevices = [NSMutableDictionary dictionary];
		
		IOBluetoothDevice *device = [IOBluetoothDevice deviceWithAddressString:self.bluetoothAddress];
		IOBluetoothRFCOMMChannel *RFCOMMChannel;
		//self.channelOpened = NO;
		IOReturn error = [device openRFCOMMChannelAsync:&RFCOMMChannel withChannelID:5 delegate:self];
		self.RFCOMMChannel = RFCOMMChannel;
		if (error != kIOReturnSuccess) {
			DLog(DLogLevelError, @"Error opening RFCOMM channel: %d", error);
			self.state = BRDeviceStateDisconnected;
			[self.delegate BRDevice:self didFailConnectWithError:error];
		}
	}
	else {
		DLog(DLogLevelWarn, @"Already connected!");
	}
#endif
	
#ifdef TARGET_IOS
	DLog(DLogLevelInfo, @"Opening connection to accessory %@...", [self.accessory name]);
	
	if (!self.isConnected) {
		if (!self.session) {
			// create data session if we found a matching accessory
			if (self.accessory) {
				self.state = BRDeviceStateOpeningLink;
				self.accessory.delegate = self;
				self.streamOpened = NO;
				self.remoteDevices = [NSMutableDictionary dictionary];
				
				DLog(DLogLevelDebug, @"Attempting to create data session with accessory %@...", [self.accessory name]);
				
#ifdef GENESIS
				self.session = [[EASession alloc] initWithAccessory:self.accessory forProtocol:@"com.plantronics.opportunity"];
#else
				self.session = [[EASession alloc] initWithAccessory:self.accessory forProtocol:BRDeviceEAProtocolString];
#endif
				if (self.session) {
#ifndef TERSE_LOGGING
					DLog(DLogLevelDebug, @"Created EA session: %@", self.session);
#endif
					
					// open input and output streams
					[[self.session inputStream] setDelegate:self];
					[[self.session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
					[[self.session inputStream] open];
					[[self.session outputStream] setDelegate:self];
					[[self.session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
					[[self.session outputStream] open];
				}
				else {
					DLog(DLogLevelError, @"Failed to create EA session.");
					DLog(DLogLevelError, @"Insure that %@ is included in the UISupportedExternalAccessoryProtocols key of your Info.plist file.", BRDeviceEAProtocolString);
					//					NSError *error = [NSError errorWithDomain:BRDeviceErrorDomain
					//														 code:BRDeviceErrorCodeFailedToCreateDataSession
					//													 userInfo:@{NSLocalizedDescriptionKey : @"Failed to create External Accessory session."}];
					[self.delegate BRDevice:self didFailConnectWithError:BRDeviceErrorFailedToCreateDataSession];
				}
			}
			else {
				DLog(DLogLevelWarn, @"No accessory accociated!");
				//				NSError *error = [NSError errorWithDomain:BRDeviceErrorDomain
				//													 code:BRDeviceErrorCodeNoAccessoryAssociated
				//												 userInfo:@{NSLocalizedDescriptionKey : @"No create External Accessory associated."}];
				[self.delegate BRDevice:self didFailConnectWithError:BRDeviceErrorNoAccessoryAssociated];
			}
		}
		else {
			DLog(DLogLevelError, @"Data session already active.");
			//			NSError *error = [NSError errorWithDomain:BRDeviceErrorDomain
			//												 code:BRDeviceErrorCodeConnectionAlreadyOpen
			//											 userInfo:@{NSLocalizedDescriptionKey : @"External Accessory data session already open."}];
			[self.delegate BRDevice:self didFailConnectWithError:BRDeviceErrorConnectionAlreadyOpen];
		} // !self.session
	} // !self.isConnected
#endif
}

- (void)closeConnection
{
#ifdef TARGET_OSX
	DLog(DLogLevelInfo, @"Closing connection (%@)...", self.bluetoothAddress);
#endif
#ifdef TARGET_IOS
	DLog(DLogLevelInfo, @"Closing connection to accessory %@...", [self.accessory name]);
#endif
	
	self.state = BRDeviceStateClosingSession;
	
	// make individual messages since remote devices will manipulate their addresses
	BRCloseSessionMessage *message = nil;
	for (NSNumber *port in self.remoteDevices) {
		message = (BRCloseSessionMessage *)[BRCloseSessionMessage message];
		BRDevice *destinationDevice = self.remoteDevices[port];
		[destinationDevice sendMessage:message];
	}
	message = (BRCloseSessionMessage *)[BRCloseSessionMessage message];
	[self sendMessage:message];
	
	[self startCloseSessionTimer];
}

//- (void)sendMessage:(BRMessage *)message
//{
//#ifdef DELAY_MESSAGES
//	if (!self.outputMessageQueue) self.outputMessageQueue = [NSMutableArray array];
//	[self.outputMessageQueue addObject:message];
//	
//	NSTimeInterval timeDelta = [[NSDate date] timeIntervalSinceDate:self.lastMessageSendDate];
//	if (!self.lastMessageSendDate || timeDelta >= MESSAGE_DELAY) {
//		DLog(DLogLevelTrace, @"%.0fms since last message >= MESSAGE_DELAY: sending...");
//		[self _sendMessage:self.outputMessageQueue[0]];
//		[self.outputMessageQueue removeObjectAtIndex:0];
//		self.checkSendMessageTimer = [NSTimer scheduledTimerWithTimeInterval:((float)MESSAGE_DELAY)/1000.0 target:self selector:@selector(checkSendMessage:) userInfo:nil repeats:NO];
//	}
//	else {
//		NSTimeInterval interval = MESSAGE_DELAY - timeDelta;
//		DLog(DLogLevelTrace, @"%.0fms since last message < MESSAGE_DELAY: waiting %.0fms.", timeDelta, interval);
//		NSTimeInterval actualInterval = ((float)interval)/1000.0;
//		DLog(DLogLevelTrace, @"actualInterval: %.2f",actualInterval);
//		if (self.checkSendMessageTimer) {
//			if ([self.checkSendMessageTimer isValid]) {
//				[self.checkSendMessageTimer invalidate];
//			}
//			self.checkSendMessageTimer = nil;
//		}
//		self.checkSendMessageTimer = [NSTimer scheduledTimerWithTimeInterval:actualInterval target:self selector:@selector(checkSendMessage:) userInfo:nil repeats:NO];
//	}
//#else
//	[self _sendMessage:message];
//#endif
//}

- (void)sendMessage:(BRMessage *)message
{
	BRMessageType messageType = BRDeviceMessageTypeFromMessageData(message.data);
	
	switch (messageType) {
		case BRMessageTypeHostProtocolVersion:
			case BRMessageTypeCloseSession:
			[self _sendMessage:message];
			break;
		default:
			if (!self.pendingOutgoingMessage) {
				self.pendingOutgoingMessage = (BROutgoingMessage *)message;
				[self _sendMessage:message];
			}
			else {
				DLog(DLogLevelDebug, @"Queueing message %@ (queue count %d)", message, [self.outgoingMessageQueue count] + 1);
				if (!self.outgoingMessageQueue) {
					self.outgoingMessageQueue = [NSMutableArray array];
				}
				[self.outgoingMessageQueue addObject:message];
			}
			break;
	}
	
	//[self _sendMessage:message];
}

#pragma mark - Private

- (void)dispatchNextOutgoingMessage
{
	DLog(DLogLevelTrace, @"dispatchNextOutgoingMessage");
	
	self.pendingOutgoingMessage = nil;
	if ([self.outgoingMessageQueue count]) {
		BRMessage *outMessage = self.outgoingMessageQueue[0];
		self.pendingOutgoingMessage = (BROutgoingMessage *)outMessage;
		[self _sendMessage:outMessage];
		[self.outgoingMessageQueue removeObjectAtIndex:0];
	}
	
	DLog(DLogLevelTrace, @"Outgoing messages left in queue: %d", [self.outgoingMessageQueue count]);
}

- (void)_sendMessage:(BRMessage *)message
{
	@synchronized(self) {
		DLog(DLogLevelDebug, @"Sending %@...", message);
		
		[self startPendingMessageTimer];
		
		// actually sends a message
		NSData *messageData = message.data; // message.data computes payload on each call...
		
#if defined(TARGET_IOS) && defined(MFI_SEQUENCE_PREFIXES)
		NSMutableData *mfiHeaderData = [[NSData dataWithHexString:@"0101"] mutableCopy]; // add MFI prefix...
		[mfiHeaderData appendData:messageData];
		messageData = mfiHeaderData;
#endif
		
		if ([message.address integerValue] == 0) {
			if ([self.delegate respondsToSelector:@selector(BRDevice:willSendData:)]) {
				[self.delegate BRDevice:self willSendData:messageData];
			}
		}
		else {
			NSString *portString = [message.address substringToIndex:1];
			uint8_t port = [portString integerValue];
			BRRemoteDevice *remoteDevice = self.remoteDevices[@(port)];
			if ([self.delegate respondsToSelector:@selector(BRDevice:willSendData:)]) {
				[remoteDevice BRDevice:self willSendData:messageData];
			}
		}
		
#ifdef TARGET_OSX
		[self.RFCOMMChannel writeAsync:(void *)[messageData bytes] length:[messageData length] refcon:nil];
#endif
#ifdef TARGET_IOS
		[self.outputBuffers addObject:messageData];
		[self checkOutputBuffers];
#endif
		
		//#ifdef DELAY_MESSAGES
		//		self.lastMessageSendDate = [NSDate date];
		//#endif
	}
}

- (void)checkInputBuffer
{
#ifndef TERSE_LOGGING
	DLog(DLogLevelTrace, @"checkInputBuffer");
#endif
	
	// the theory is that the beginning of the data will always be the start of a message
	// the buffer may not contain a whole message, or it may overflow into part or all of a new message
	
	for (;;) {
		if ([self.inputBuffer length] >= 5) {
			uint16_t msg_len = 0;
			[[self.inputBuffer subdataWithRange:NSMakeRange(1, sizeof(uint16_t)-1)] getBytes:&msg_len length:sizeof(uint16_t)-1];
			msg_len += 2; // add "address type" and actual length bytes
			
			// three cases:
			// 1: [data length] and msg_len are the same. we've got exactly one full message.
			//		send it to be parsed, clear accumulatedInputData, and break
			// 2: [data length] is shorter msg_len
			//		leave accumulatedInputData alone and break (and wait for us to be called again with more data)
			// 3: [data length] is larger than msg_len
			//		take [data length] out of accumulatedInputData, send it to be parsed, loop to try next chunk
			
			if ([self.inputBuffer length] == msg_len) {
				[self parseIncomingMessage:self.inputBuffer];
				self.inputBuffer = [NSMutableData data];
				break;
			}
			else if ([self.inputBuffer length] < msg_len) {
				break;
			}
			else if ([self.inputBuffer length] > msg_len) {
				NSRange range = NSMakeRange(0, msg_len);
				NSData *messageData = [self.inputBuffer subdataWithRange:range];
				[self.inputBuffer replaceBytesInRange:range withBytes:nil length:0];
				//self.inputBuffer = [[self.inputBuffer subdataWithRange:NSMakeRange(msg_len, [data length] - msg_len)] mutableCopy];
				[self parseIncomingMessage:messageData];
			}
		}
		else {
			// not enough data for header
			break;
		}
	}
}

#ifdef TARGET_IOS

- (void)checkOutputBuffers
{
#ifndef TERSE_LOGGING
	DLog(DLogLevelTrace, @"checkOutputBuffers: (num messages: %d)", [self.outputBuffers count]);
#endif
	NSOutputStream *outputStream = [self.session outputStream];
	NSMutableData *outData;
	if ([self.outputBuffers count]) {
#ifndef TERSE_LOGGING
		DLog(DLogLevelTrace, @"*** SENDING ***");
#endif
		outData = self.outputBuffers[0];
	}
	else {
#ifndef TERSE_LOGGING
		DLog(DLogLevelTrace, @"*** NOTHING TO SEND ***");
#endif
	}
	while(self.session && [outputStream hasSpaceAvailable] && [outData length]) {
#ifndef TERSE_LOGGING
		DLog(DLogLevelTrace, @"(data)");
#endif
		NSInteger len = [outputStream write:(void *)[outData bytes] maxLength:[outData length]];
		switch (len) {
			case 0: // reached fixed-length capacity (?)
				break;
			case -1: { // error
				NSError *error = [outputStream streamError];
				DLog(DLogLevelError, @"****** Stream error: %@ ******", error);
#warning handle?
				break; }
			default: { // data written
				DLog(DLogLevelTrace, @"Wrote %ld bytes.", (long)len);
				if (len == [outData length]) {
#ifndef TERSE_LOGGING
					DLog(DLogLevelTrace, @"(whole message)");
#endif
					[self.outputBuffers removeObjectAtIndex:0];
				}
				else {
#ifndef TERSE_LOGGING
					DLog(DLogLevelTrace, @"(partial message)");
#endif
#warning wait and re-send whole message at once?
					NSRange range = NSMakeRange(0, len);
					[outData replaceBytesInRange:range withBytes:nil length:0];
				}
				break; }
		}
		
		if ([self.outputBuffers count]) {
			outData = self.outputBuffers[0];
		}
	}
}

#endif

- (void)parseIncomingMessage:(NSData *)data
{
	DLog(DLogLevelTrace, @"parseIncomingMessage:");
	
	if ([self.delegate respondsToSelector:@selector(BRDevice:didReceiveData:)]) {
		[self.delegate BRDevice:self didReceiveData:data];
	}
	
	@try {
		NSString *address = [BRDeviceHexStringFromData([data subdataWithRange:NSMakeRange(2, sizeof(uint32_t))], 0) substringToIndex:6];
		NSString *portString = [address substringToIndex:2];
		uint8_t port = [portString integerValue];
		BRDevice *destinationDevice = self.remoteDevices[@(port)];
		if (!destinationDevice) destinationDevice = self;
		
//		uint8_t messageType;
//		NSData *messageTypeData = [data subdataWithRange:NSMakeRange(5, sizeof(uint8_t))];
//		[messageTypeData getBytes:&messageType length:sizeof(uint8_t)];
//		messageType &= 0x0F; // messageType is actually the second nibble in byte 5
		BRMessageType messageType = BRDeviceMessageTypeFromMessageData(data);
		
		switch (messageType) {
			case BRMessageTypeDeviceProtocolVersion: {
				BRDeviceProtocolVersionMessage *protocolVersionMessage = (BRDeviceProtocolVersionMessage *)[BRDeviceProtocolVersionMessage messageWithData:data];
				DLog(DLogLevelTrace, @"BRMessageTypeDeviceProtocolVersion: %@", protocolVersionMessage);
				destinationDevice.state = BRDeviceStateAwaitingMetadata;
				break; }
				
			case BRMessageTypeMetadata: {
				BRMetadataMessage *metadata = (BRMetadataMessage *)[BRMetadataMessage messageWithData:data];
				DLog(DLogLevelTrace, @"BRMessageTypeMetadata: %@", metadata);
				if (destinationDevice == self) {
					self.commands = metadata.commands;
					self.settings = metadata.settings;
					self.events = metadata.events;
					self.state = BRDeviceStateConnected;
					[self.delegate BRDeviceDidConnect:self];
				}
				else {
					[(BRRemoteDevice *)destinationDevice BRDevice:self didReceiveMetadata:metadata];
				}
				break; }
				
			case BRMessageTypeCloseSession:
				DLog(DLogLevelTrace, @"BRMessageTypeCloseSession");
				break;
				
			case BRMessageTypeProtocolVersionRejection:
				DLog(DLogLevelTrace, @"BRMessageTypeProtocolVersionRejection");;
				break;
				
			case BRMessageTypeConnectionChangeEvent:
				DLog(DLogLevelTrace, @"BRMessageTypeConnectionChangeEvent");
				break;
				
			case BRMessageTypeCommandResultSuccess: {
				BRCommandResult *result = (BRCommandResult *)[BRIncomingMessageDecoder messageWithData:data];
#ifdef TERSE_LOGGING
				DLog(DLogLevelTrace, @"BRMessageTypeCommandResultSuccess: %@", NSStringFromClass([result class]));
#else
				DLog(DLogLevelTrace, @"BRMessageTypeCommandResultSuccess: %@", result);
#endif
				
				[self checkAndDispatchNextOutgoingMessage:result];
				
				break; }
				
			case BRMessageTypeCommandResultException: {
				BRException *exception = (BRException *)[BRIncomingMessageDecoder messageWithData:data];
#ifdef TERSE_LOGGING
				DLog(DLogLevelTrace, @"BRMessageTypeCommandResultException: %@", NSStringFromClass([exception class]));
#else
				DLog(DLogLevelTrace, @"BRMessageTypeCommandResultException: %@", exception);
#endif
				
				[self checkAndDispatchNextOutgoingMessage:exception];
				
				if (destinationDevice == self) {
					[self.delegate BRDevice:self didRaiseCommandException:exception];
				}
				else {
					[(BRRemoteDevice *)destinationDevice BRDevice:destinationDevice didRaiseCommandException:exception];
				}
				break; }
				
			case BRMessageTypeSettingResultSuccess: {
				BRSettingResult *result = (BRSettingResult *)[BRIncomingMessageDecoder messageWithData:data];
#ifdef TERSE_LOGGING
				DLog(DLogLevelTrace, @"BRMessageTypeSettingResultSuccess: %@", NSStringFromClass([result class]));
#else
				DLog(DLogLevelTrace, @"BRMessageTypeSettingResultSuccess: %@", result);
#endif
				
				[self checkAndDispatchNextOutgoingMessage:result];
				
				if (destinationDevice == self) {
					[self.delegate BRDevice:self didReceiveSettingResult:result];
				}
				else {
					[(BRRemoteDevice *)destinationDevice BRDevice:destinationDevice didReceiveSettingResult:result];
				}
				break; }
				
			case BRMessageTypeSettingResultException: {
				BRException *exception = (BRException *)[BRIncomingMessageDecoder messageWithData:data];
#ifdef TERSE_LOGGING
				DLog(DLogLevelTrace, @"BRMessageTypeSettingResultException: %@", NSStringFromClass([exception class]));
#else
				DLog(DLogLevelTrace, @"BRMessageTypeSettingResultException: %@", exception);
#endif
				[self checkAndDispatchNextOutgoingMessage:exception];
				
				if (destinationDevice == self) {
					[self.delegate BRDevice:self didRaiseSettingException:exception];
				}
				else {
					[(BRRemoteDevice *)destinationDevice BRDevice:destinationDevice didRaiseSettingException:exception];
				}
				break; }
				
			case BRMessageTypeEvent: {
				BREvent *event = (BREvent *)[BRIncomingMessageDecoder messageWithData:data];
#ifdef TERSE_LOGGING
				DLog(DLogLevelTrace, @"BRMessageTypeEvent: %@", NSStringFromClass([event class]));
#else
				DLog(DLogLevelTrace, @"BRMessageTypeEvent: %@", event);
#endif
				
				if ([event isKindOfClass:[BRConnectedDeviceEvent class]]) {
					uint8_t devPort;
					[[event.data subdataWithRange:NSMakeRange(8, sizeof(uint8_t))] getBytes:&devPort length:sizeof(uint8_t)];
					BRRemoteDevice *remoteDevice = [BRRemoteDevice deviceWithParent:self port:devPort];
					((NSMutableDictionary *)self.remoteDevices)[@(devPort)] = remoteDevice;
					[self.delegate BRDevice:self didFindRemoteDevice:remoteDevice];
				}
				else if ([event isKindOfClass:[BRDisconnectedDeviceEvent class]]) {
					uint8_t devPort;
					[[event.data subdataWithRange:NSMakeRange(8, sizeof(uint8_t))] getBytes:&devPort length:sizeof(uint8_t)];
					BRRemoteDevice *remoteDevice = self.remoteDevices[@(devPort)];
					[((NSMutableDictionary *)self.remoteDevices) removeObjectForKey:@(devPort)];
					[remoteDevice BRDeviceDidDisconnect:remoteDevice];
				}
				else {
					if (destinationDevice == self) {
						[self.delegate BRDevice:self didReceiveEvent:event];
					}
					else {
						[(BRRemoteDevice *)destinationDevice BRDevice:destinationDevice didReceiveEvent:event];
					}
				}
				break; }
				
			default:
				DLog(DLogLevelWarn, @"Error: unknown message type 0x%01X", messageType);
				break;
		}
	}
	@catch(NSException *e) {
		// (INTENDED FOR IOS ONLY)
		// usaully each time the accessory's input stream has NSStreamEventHasBytesAvailable, there is a 2-byte prefix on the data.
		// this is usually chopped off before adding the data to the input buffer.
		// sometimes (such as handshaking with port 5) while other data is rapidly coming through (head tracking service was previously subscribed to)
		// a chunk of data will arrive at NSStreamEventHasBytesAvailable that has a second 2-byte prefix in the body of the data
		// this causes parsing errors. so far, ignoring the exceptions seems to work pretty well, but there is probably a "real" solution.
		// this is possibly a firmware issue, an application issue buffering input, and OS issue buffering input, or related to combinations of the NSStreamEvent bitmasks.
		DLog(DLogLevelError, @"************ EXCEPTION PARSING MESSAGE DATA: %@ ************", e);
	}
}

- (void)checkAndDispatchNextOutgoingMessage:(BRIncomingMessage *)incomingMessage
{
	DLog(DLogLevelTrace, @"checkAndDispatchNextOutboundMessage: %@", incomingMessage);
	
	BRMessageType i_messageType = BRDeviceMessageTypeFromMessageData(incomingMessage.data);
	uint16_t i_deckardID = BRDeviceDeckardIDFromMessageData(incomingMessage.data);
	
	BRMessageType p_messageType = BRDeviceMessageTypeFromMessageData(self.pendingOutgoingMessage.data);
	uint16_t p_deckardID = BRDeviceDeckardIDFromMessageData(self.pendingOutgoingMessage.data);
	
	BOOL match = NO;
	if (i_deckardID == p_deckardID) {
		switch (p_messageType) {
			case BRMessageTypeCommand:
				if (i_messageType==BRMessageTypeCommandResultSuccess || i_messageType==BRMessageTypeCommandResultException) {
					match = YES;
				}
				break;
			case BRMessageTypeSettingRequest:
				if (i_messageType==BRMessageTypeSettingResultSuccess || i_messageType==BRMessageTypeSettingResultException) {
					match = YES;
				}
				break;
			default:
				match = NO;
				break;
		}
	}
	
	if (match) {
		DLog(DLogLevelTrace, @"Matches pending message.");
		[self stopPendingMessageTimer];
		[self dispatchNextOutgoingMessage];
	}
	else {
		DLog(DLogLevelError, @"*** Unexpected result message ***");
	}
}

- (void)startCloseSessionTimer
{
	DLog(DLogLevelTrace, @"startCloseSessionTimer");
	
	[self cancelCloseSessionTimer];
	self.closeSessionTimer = [NSTimer scheduledTimerWithTimeInterval:(float)DISCONNECT_DELAY/1000.0 target:self selector:@selector(closeSessionTimer:) userInfo:nil repeats:NO];
	
	self.state = BRDeviceStateClosingSession;
}

- (void)cancelCloseSessionTimer
{
	DLog(DLogLevelTrace, @"cancelCloseSessionTimer");
	
	if ([self.closeSessionTimer isValid]) {
		[self.closeSessionTimer invalidate];
	}
	self.closeSessionTimer = nil;
	
	self.state = BRDeviceStateConnected; // ya?
}

- (void)closeSessionTimer:(NSTimer *)aTimer
{
	DLog(DLogLevelTrace, @"closeSessionTimer:");
	
	self.state = BRDeviceStateClosingLink;
	
#ifdef TARGET_OSX
	DLog(DLogLevelInfo, @"Closing RFCOMM channel...");
	
	[self.RFCOMMChannel closeChannel];
	self.RFCOMMChannel = nil;
	
	// wait for RFCOMMChannel callbacks for self.state = BRDeviceStateDisconnected
#endif
	
#ifdef TARGET_IOS
	DLog(DLogLevelInfo, @"Closing External Accessory session...");
	
	[[self.session inputStream] close];
	[[self.session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[[self.session inputStream] setDelegate:nil];
	[[self.session outputStream] close];
	[[self.session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[[self.session outputStream] setDelegate:nil];
	self.session = nil;
	self.streamOpened = NO;
	
	self.state = BRDeviceStateDisconnected;
	
	for (NSNumber *port in self.remoteDevices) {
		id destinationDevice = self.remoteDevices[port];
		[destinationDevice BRDeviceDidDisconnect:self];
	}
	[self.delegate BRDeviceDidDisconnect:self];
#endif
}

- (void)startPendingMessageTimer
{
	DLog(DLogLevelTrace, @"startPendingMessageTimer");
	
	[self stopPendingMessageTimer];
	self.pendingMessageTimer = [NSTimer scheduledTimerWithTimeInterval:(float)PENDING_MESSAGE_TIMEOUT/1000.0 target:self selector:@selector(pendingMessageTimer:) userInfo:nil repeats:NO];
}

- (void)stopPendingMessageTimer
{
	DLog(DLogLevelTrace, @"stopPendingMessageTimer");
	
	if ([self.pendingMessageTimer isValid]) {
		[self.pendingMessageTimer invalidate];
	}
	self.pendingMessageTimer = nil;
}

- (void)pendingMessageTimer:(NSTimer *)aTimer
{
	DLog(DLogLevelTrace, @"pendingMessageTimer");
	
	[self dispatchNextOutgoingMessage];
}

//#ifdef DELAY_MESSAGES
//- (void)checkSendMessage:(NSTimer *)aTimer
//{
//	DLog(DLogLevelTrace, @"checkSendMessage:");
//	
//	if ([self.outputMessageQueue count]) {
//		[self _sendMessage:self.outputMessageQueue[0]];
//		[self.outputMessageQueue removeObjectAtIndex:0];
//		
//		if (self.checkSendMessageTimer) {
//			if ([self.checkSendMessageTimer isValid]) {
//				[self.checkSendMessageTimer invalidate];
//			}
//			self.checkSendMessageTimer = nil;
//		}
//		self.checkSendMessageTimer = [NSTimer scheduledTimerWithTimeInterval:((float)MESSAGE_DELAY)/1000.0 target:self selector:@selector(checkSendMessage:) userInfo:nil repeats:NO];
//	}
//}
//#endif

#pragma mark - IOBluetoothRFCOMMChannelDelegate

#ifdef TARGET_OSX
- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel *)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength
{
    NSData *data = [NSData dataWithBytes:dataPointer length:dataLength];
	//DLog(DLogLevelTrace, @"<== %@", [data hexStringWithSpaceEvery:2]);
	
	[self.inputBuffer appendData:data];
	[self checkInputBuffer];
	
    //[self parseIncomingMessage:data];
}

- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel *)rfcommChannel status:(IOReturn)error
{
    DLog(DLogLevelTrace, @"rfcommChannelOpenComplete: %@, status: %d", rfcommChannel, error);
	
	self.inputBuffer = [NSMutableData data];
	
	if (!rfcommChannel.isOpen) {
		// when an invalid BT address is supplied, error is 4. not sure where this comes from.
		[self.delegate BRDevice:self didFailConnectWithError:error];
	}
	else {
		if (self.state == BRDeviceStateOpeningLink) {
			self.state = BRDeviceStateHostVersionNegotiating;
#ifdef GENESIS
			BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeHostProtocolVersion payload:[NSData dataWithHexString:@"646E"]];
			[self sendMessage:message];	
#else
			BRHostVersionNegotiateMessage *message = (BRHostVersionNegotiateMessage *)[BRHostVersionNegotiateMessage messageWithMinimumVersion:1 maximumVersion:1];
			[self sendMessage:message];	
#endif
		}
	}
}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
    DLog(DLogLevelTrace, @"rfcommChannelClosed:");
	
    self.state = BRDeviceStateDisconnected;
	
	for (NSNumber *port in self.remoteDevices) {
		id destinationDevice = self.remoteDevices[port];
		[destinationDevice BRDeviceDidDisconnect:self];
	}
    [self.delegate BRDeviceDidDisconnect:self];
}

- (void)rfcommChannelControlSignalsChanged:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
    DLog(DLogLevelTrace, @"rfcommChannelControlSignalsChanged:");
}

- (void)rfcommChannelFlowControlChanged:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
    DLog(DLogLevelTrace, @"rfcommChannelFlowControlChanged: %d", [rfcommChannel getMTU]);
}

- (void)rfcommChannelWriteComplete:(IOBluetoothRFCOMMChannel *)rfcommChannel refcon:(void*)refcon status:(IOReturn)error
{
    //NSLog(@"rfcommChannelWriteComplete: %d", error);
}

- (void)rfcommChannelQueueSpaceAvailable:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
    //DLog(DLogLevelTrace, @"rfcommChannelQueueSpaceAvailable:");
    
    if (![rfcommChannel isOpen]) {
        if (self.state == BRDeviceStateOpeningLink) {
            self.state = BRDeviceStateHostVersionNegotiating;
#ifdef GENESIS
			BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeHostProtocolVersion payload:[NSData dataWithHexString:@"646E"]];
			[self sendMessage:message];	
#else
			BRHostVersionNegotiateMessage *message = (BRHostVersionNegotiateMessage *)[BRHostVersionNegotiateMessage messageWithMinimumVersion:1 maximumVersion:1];
			[self sendMessage:message];	
#endif
        }
    }
}
#endif

#pragma mark - EAAccessoryDelegate

#ifdef TARGET_IOS
- (void)accessoryDidDisconnect:(EAAccessory *)accessory
{
	DLog(DLogLevelWarn, @"accessoryDidDisconnect: %@", accessory);
	
	[self closeSessionTimer:nil];
}
#endif

#pragma mark - NSStreamDelegate

#ifdef TARGET_IOS
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
	//NSLog(@"handleEvent: %lu", streamEvent);
	
	// OPEN COMPLETED
	if (streamEvent & NSStreamEventOpenCompleted) {
		DLog(DLogLevelTrace, @"NSStreamEventOpenCompleted");
		self.inputBuffer = [NSMutableData data];
		self.outputBuffers = [NSMutableArray array];
	}
	
	// SPACE AVAILABLE
	if (streamEvent & NSStreamEventHasSpaceAvailable) {
		//NSLog(@"NSStreamEventHasSpaceAvailable");
		if (!self.streamOpened) {
			self.streamOpened = YES;
			if (self.state == BRDeviceStateOpeningLink) {
				self.state = BRDeviceStateHostVersionNegotiating;
#ifdef GENESIS
				BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeHostProtocolVersion payload:[NSData dataWithHexString:@"646E"]];
				[self sendMessage:message];	
#else
				BRHostVersionNegotiateMessage *message = (BRHostVersionNegotiateMessage *)[BRHostVersionNegotiateMessage messageWithMinimumVersion:1 maximumVersion:1];
				[self sendMessage:message];
#endif
			}
		}
		[self checkOutputBuffers];
	}
	
	// BYTES AVAILABLE
	if (streamEvent & NSStreamEventHasBytesAvailable) {
		//NSLog(@"NSStreamEventHasBytesAvailable:");
		
		uint8_t buf[4096*4]; // maximum deckard message size (with address type 1) x 4.
		NSUInteger len = [[self.session inputStream] read:buf maxLength:4096*4];
		
		NSData *data = [NSData dataWithBytes:buf length:len];
		
		DLog(DLogLevelTrace, @"<== %@", BRDeviceHexStringFromData(data, 2));

		// since the "MFI prefix" is added to every BUFFER, not every MESSAGE, from it for each buffer
#ifdef MFI_SEQUENCE_PREFIXES
		data = [data subdataWithRange:NSMakeRange(2, [data length]-2)];
#endif
		
		[self.inputBuffer appendData:data];
		[self checkInputBuffer];
		//[self parseIncomingMessage:data];
	}
	
	// END ENCOUNTERED
	if (streamEvent & NSStreamEventEndEncountered) {
		DLog(DLogLevelTrace, @"NSStreamEventEndEncountered");
	}
	
	// ERROR OCCURRED
	if (streamEvent & NSStreamEventErrorOccurred) {
		NSError *error = [theStream streamError];
		NSString *errorMessage = [NSString stringWithFormat:@"%@ (code %ld)", [error localizedDescription], (long)[error code]];
		DLog(DLogLevelError, @"NSStreamEventErrorOccurred: %@", errorMessage);
	}
	
	// NONE
	if (streamEvent & NSStreamEventNone) {
		//NSLog(@"NSStreamEventNone");
	}
}
#endif

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[BRDevice class]]) {
#ifdef TARGET_OSX
		return [((BRDevice *)object).bluetoothAddress isEqualToString:self.bluetoothAddress];
#endif
#ifdef TARGET_IOS
		EAAccessory *compareAccessory = ((BRDevice *)object).accessory;
		return (self.accessory.connectionID == compareAccessory.connectionID);
#endif
	}
	return NO;
}

- (NSString *)description
{
#ifdef TARGET_OSX
	#ifdef TERSE_LOGGING
		return [NSString stringWithFormat:@"<BRDevice %p> bluetoothAddress=%@",
				self, self.bluetoothAddress];
	#else
		return [NSString stringWithFormat:@"<BRDevice %p> bluetoothAddress=%@, isConnected=%@, commands=(%lu), settings=(%lu), events=(%lu), remoteDevices=(%lu), delegate=%@",
				self, self.bluetoothAddress, (self.isConnected ? @"YES" : @"NO"), (unsigned long)[self.commands count], (unsigned long)[self.settings count], 
				(unsigned long)[self.events count], (unsigned long)[self.remoteDevices count], self.delegate];
	#endif
#endif
#ifdef TARGET_IOS
	#ifdef TERSE_LOGGING
	return [NSString stringWithFormat:@"<BRDevice %p> accessory.name=%@",
            self, self.accessory.name];
	#else
		return [NSString stringWithFormat:@"<BRDevice %p> accessory=%@, isConnected=%@, commands=(%lu), settings=(%lu), events=(%lu), remoteDevices=(%d), delegate=%@",
				self, self.accessory.name, (self.isConnected ? @"YES" : @"NO"), (unsigned long)[self.commands count], (unsigned long)[self.settings count], 
				(unsigned long)[self.events count], [self.remoteDevices count], self.delegate];
	#endif
#endif
}

@end
