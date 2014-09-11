//
//  BRDevice.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "Configuration.h"
#import "PLTDLog.h"
#import "BRDevice.h"
#import "BRDevice_Private.h"
#import "BRMessage_Private.h"
#import "BRIncomingMessage_Private.h"
#import "BROutgoingMessage_Private.h"
#import "BRRemoteDevice_Private.h"
#import "BRRemoteDevice.h"
#import "BRMessage.h"
#import "BRSubscribeToServiceCommand.h"
#import "BROrientationTrackingEvent.h"
#import "BRTapsEvent.h"
#import "BRFreeFallEvent.h"
#import "BRPedometerEvent.h"
#import "BRMagnetometerCalStatusEvent.h"
#import "BRGyroscopeCalStatusEvent.h"
#import "BRWearingStateSettingResponse.h"
#import "BROrientationTrackingSettingResponse.h"
#import "BRWearingStateEvent.h"
#import "BRSignalStrengthEvent.h"
#import "BRSignalStrengthSettingResponse.h"
#import "BRDeviceInfoSettingResponse.h"
#import "BRTapsSettingResponse.h"
#import "BRFreeFallSettingResponse.h"
#import "BRPedometerSettingResponse.h"
#import "BRGyroscopeCalStatusSettingResponse.h"
#import "BRMagnetometerCalStatusSettingResponse.h"
#import "BRDeviceNotReadyException.h"
#import "BRIllegalValueException.h"
#import "BRDeviceConnectedEvent.h"
#import "BRDeviceDisconnectedEvent.h"
#import "BRServiceSubscriptionChangedEvent.h"
#import "BRHostVersionNegotiateMessage.h"
#import "BRMetadataMessage.h"
#import "BRCloseSessionMessage.h"
#import "BRDeviceProtocolVersionMessage.h"
#import "BRGenesGUIDSettingResponse.h"
#import "BRProductNameSettingResponse.h"
#import "NSData+HexStrings.h"
#import "NSArray+PrettyPrint.h"
#import "BRConnectionStatusSettingResponse.h"
#import "BRCustomButtonEvent.h"
#import "BRHeadsetCallStatusEvent.h"
#import "BRHeadsetCallStatusSettingResponse.h"

#import "BRSubscribedServiceDataEvent.h"

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


#define DISCONNECT_DELAY	250 // ms

#ifdef TARGET_IOS
NSString *const BRDeviceEAProtocolString =							@"com.plantronics.headsetdataservice";
NSString *const BRDeviceErrorDomain =								@"com.plantronics.BRDevice";
#endif


#ifdef TARGET_OSX
@interface BRDevice ()
#endif
#ifdef TARGET_IOS
@interface BRDevice () <EAAccessoryDelegate, NSStreamDelegate>
#endif

- (void)checkInputBuffer;
#ifdef TARGET_IOS
- (void)checkOutputBuffers;
#endif
- (void)parseIncomingMessage:(NSData *)data;
- (void)startCloseSessionTimer;
- (void)cancelCloseSessionTimer;
- (void)closeSessionTimer:(NSTimer *)aTimer;

@property(nonatomic,strong)				NSMutableData				*inputBuffer;
@property(nonatomic,strong,readwrite)	NSMutableDictionary			*remoteDevices;
@property(nonatomic,strong)				NSTimer						*closeSessionTimer;
#ifdef TARGET_OSX
@property(nonatomic,strong)             IOBluetoothRFCOMMChannel    *RFCOMMChannel;
//@property(nonatomic,assign)             BOOL                        channelOpened;
#endif
#ifdef TARGET_IOS
@property(nonatomic,strong)				EASession					*session;
@property(nonatomic,assign)             BOOL                        streamOpened;
@property(nonatomic,strong)				NSMutableArray				*outputBuffers;


//#warning TEMPORARY FOR IAP PARSE ERROR
//#define OUTPUT_DELAY	.25
//@property(nonatomic,strong)				NSTimer						*outputTimer;
//@property(nonatomic,strong)				NSDate						*lastOutputDate;

#endif

@end



@implementation BRDevice

@dynamic isConnected;

- (BOOL)isConnected
{
	return self.state == BRDeviceStateConnected;
}

#pragma mark - Public

#ifdef TARGET_OSX
+ (BRDevice *)deviceWithAddress:(NSString *)bluetoothAddress
{
    BRDevice *device = [[BRDevice alloc] init];
    device.bluetoothAddress = bluetoothAddress;
    return device;
}

//- (void)openConnection
//{
//    NSLog(@"Opening connection to device at address %@...", self.bluetoothAddress);
//    
//	if (!self.isConnected) {
//		self.state = BRDeviceStateOpeningLink;
//		self.remoteDevices = [NSMutableDictionary dictionary];
//		
//		IOBluetoothDevice *device = [IOBluetoothDevice deviceWithAddressString:self.bluetoothAddress];
//		IOBluetoothRFCOMMChannel *RFCOMMChannel;
//		//self.channelOpened = NO;
//		IOReturn error = [device openRFCOMMChannelAsync:&RFCOMMChannel withChannelID:5 delegate:self];
//		self.RFCOMMChannel = RFCOMMChannel;
//		if (error != kIOReturnSuccess) {
//			NSLog(@"Error opening RFCOMM channel: %d", error);
//			self.state = BRDeviceStateDisconnected;
//			[self.delegate BRDevice:self didFailConnectWithError:error];
//		}
//	}
//	else {
//		NSLog(@"Already connected!");
//	}
//}

//- (void)closeConnection
//{
//    NSLog(@"Closing connection (%@)...", self.bluetoothAddress);
//    
//	self.state = BRDeviceStateClosingSession;
//	
//    BRCloseSessionMessage *message = (BRCloseSessionMessage *)[BRCloseSessionMessage message];
//    [self sendMessage:message];
//	
//	[self startCloseSessionTimer];
//    
//    //[self.RFCOMMChannel closeChannel];
//	//self.isConnected = NO;
//}
#endif

#ifdef TARGET_IOS
+ (BRDevice *)deviceWithAccessory:(EAAccessory *)anAccessory
{
    BRDevice *device = [[BRDevice alloc] init];
    device.accessory = anAccessory;
    return device;
}

//- (void)openConnection
//{
//    NSLog(@"Opening session with accessory %@...", self.accessory);
//	
//	if (!self.isConnected) {
//		if (!self.session) {
//			// create data session if we found a matching accessory
//			if (self.accessory) {
//				self.state = BRDeviceStateOpeningLink;
//				self.streamOpened = NO;
//				self.remoteDevices = [NSMutableDictionary dictionary];
//				
//				NSLog(@"Attempting to create data session with accessory %@", [self.accessory name]);
//				
//#ifdef GENESIS
//				self.session = [[EASession alloc] initWithAccessory:self.accessory forProtocol:@"com.plantronics.opportunity"];
//#else
//				self.session = [[EASession alloc] initWithAccessory:self.accessory forProtocol:BRDeviceEAProtocolString];
//#endif
//				if (self.session) {
//					NSLog(@"Created EA session: %@", self.session);
//					
//					// open input and output streams
//					[[self.session inputStream] setDelegate:self];
//					[[self.session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//					[[self.session inputStream] open];
//					[[self.session outputStream] setDelegate:self];
//					[[self.session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//					[[self.session outputStream] open];
//				}
//				else {
//					NSLog(@"Failed to create EA session.");
////					NSError *error = [NSError errorWithDomain:BRDeviceErrorDomain
////														 code:BRDeviceErrorCodeFailedToCreateDataSession
////													 userInfo:@{NSLocalizedDescriptionKey : @"Failed to create External Accessory session."}];
//					[self.delegate BRDevice:self didFailConnectWithError:BRDeviceErrorCodeFailedToCreateDataSession];
//				}
//			}
//			else {
//				NSLog(@"No accessory accociated!");
////				NSError *error = [NSError errorWithDomain:BRDeviceErrorDomain
////													 code:BRDeviceErrorCodeNoAccessoryAssociated
////												 userInfo:@{NSLocalizedDescriptionKey : @"No create External Accessory associated."}];
//				[self.delegate BRDevice:self didFailConnectWithError:BRDeviceErrorCodeNoAccessoryAssociated];
//			}
//		}
//		else {
//			NSLog(@"Data session already active.");
////			NSError *error = [NSError errorWithDomain:BRDeviceErrorDomain
////												 code:BRDeviceErrorCodeConnectionAlreadyOpen
////											 userInfo:@{NSLocalizedDescriptionKey : @"External Accessory data session already open."}];
//			[self.delegate BRDevice:self didFailConnectWithError:BRDeviceErrorCodeConnectionAlreadyOpen];
//		} // !self.session
//	} // !self.isConnected
//}
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
	DLog(DLogLevelInfo, @"Opening session with accessory %@...", self.accessory);
	
	if (!self.isConnected) {
		if (!self.session) {
			// create data session if we found a matching accessory
			if (self.accessory) {
				self.state = BRDeviceStateOpeningLink;
				self.accessory.delegate = self;
				self.streamOpened = NO;
				self.remoteDevices = [NSMutableDictionary dictionary];
				
				DLog(DLogLevelDebug, @"Attempting to create data session with accessory %@", [self.accessory name]);
				
#ifdef GENESIS
				self.session = [[EASession alloc] initWithAccessory:self.accessory forProtocol:@"com.plantronics.opportunity"];
#else
				self.session = [[EASession alloc] initWithAccessory:self.accessory forProtocol:BRDeviceEAProtocolString];
#endif
				if (self.session) {
					DLog(DLogLevelDebug, @"Created EA session: %@", self.session);
					
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
	DLog(DLogLevelInfo, @"Closing connection to accessory %@...", self.accessory);
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

- (void)sendMessage:(BRMessage *)message
{
	NSData *messageData = message.data; // message.data computes on each call...
	
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
	else {//([message.address integerValue] != 0) {
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
	//[self.outputBuffer appendData:messageData];
	[self checkOutputBuffers];
	//[[self.session outputStream] write:(void *)[messageData bytes] maxLength:[messageData length]];
#endif
}

#pragma mark - Private

- (void)checkInputBuffer
{
	DLog(DLogLevelTrace, @"checkInputBuffer");
	
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

//#warning TEMPORARY
//- (void)outputTimer:(NSTimer *)timer
//{
//	//NSLog(@"*** OUTPUT TIMER: %@ ***", timer);
//	[self.outputTimer invalidate];
//	self.outputTimer = nil;
//	[self checkOutputBuffers];
//}

- (void)checkOutputBuffers
{
	DLog(DLogLevelTrace, @"checkOutputBuffers: (num messages: %d)", [self.outputBuffers count]);
	
//	NSTimeInterval timeSinceLastOutput = [[NSDate date] timeIntervalSinceDate:self.lastOutputDate];
//	if (!self.lastOutputDate || timeSinceLastOutput >= OUTPUT_DELAY) {
		
		NSOutputStream *outputStream = [self.session outputStream];
		NSMutableData *outData;
		if ([self.outputBuffers count]) {
			DLog(DLogLevelTrace, @"*** SENDING ***");
			outData = self.outputBuffers[0];
		}
		else {
			DLog(DLogLevelTrace, @"*** NOTHING TO SEND ***");
		}
		//if ([outData length]) {
		while(self.session && [outputStream hasSpaceAvailable] && [outData length]) {
			DLog(DLogLevelTrace, @"(data)");
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
						DLog(DLogLevelTrace, @"(whole message)");
						[self.outputBuffers removeObjectAtIndex:0];
					}
					else {
						DLog(DLogLevelTrace, @"(partial message)");
#warning wait and re-send whole message at once?
						NSRange range = NSMakeRange(0, len);
						[outData replaceBytesInRange:range withBytes:nil length:0];
					}
					break; }
			}
			
			if ([self.outputBuffers count]) {
				outData = self.outputBuffers[0];
			}
			
			//self.lastOutputDate = [NSDate date];
		}
//	}
//	else {
//		//NSLog(@"*** WAITING ***");
//		if (!self.outputTimer) {
//			//NSLog(@"*** STARTING TIMR ***");
//			self.outputTimer = [NSTimer scheduledTimerWithTimeInterval:OUTPUT_DELAY target:self selector:@selector(outputTimer:) userInfo:nil repeats:NO];
//		}
//	}
}

//- (void)checkOutputBuffer
//{
//	NSLog(@"checkOutputBuffer:");
//	
//	NSOutputStream *outputStream = [self.session outputStream];
//	while([outputStream hasSpaceAvailable] && [self.outputBuffer length]) {
//		NSLog(@"(data)");
//			NSInteger len = [outputStream write:(void *)[self.outputBuffer bytes] maxLength:[self.outputBuffer length]];
//			switch (len) {
//				case 0: // reached fixed-length capacity (?)
//					break;
//				case -1: { // error
//					NSError *error = [outputStream streamError];
//					NSLog(@"****** Stream error: %@ ******", error);
//#warning handle?
//					break; }
//				default: { // data written
//					NSLog(@"Wrote %d bytes.", len);
//					NSRange range = NSMakeRange(0, len);
//					[self.outputBuffer replaceBytesInRange:range withBytes:nil length:0];
//					break; }
//			}
//	}
//}
#endif

- (void)parseIncomingMessage:(NSData *)data
{
	DLog(DLogLevelTrace, @"parseIncomingMessage:");
	
	if ([self.delegate respondsToSelector:@selector(BRDevice:didReceiveData:)]) {
		[self.delegate BRDevice:self didReceiveData:data];
	}
	
	@try {
		NSString *address = [[[data subdataWithRange:NSMakeRange(2, sizeof(uint32_t))] hexStringWithSpaceEvery:0] substringToIndex:6];
		NSString *portString = [address substringToIndex:2];
		uint8_t port = [portString integerValue];
		BRDevice *destinationDevice = self.remoteDevices[@(port)];
		if (!destinationDevice) destinationDevice = self;
		
		uint8_t messageType;
		NSData *messageTypeData = [data subdataWithRange:NSMakeRange(5, sizeof(uint8_t))];
		[messageTypeData getBytes:&messageType length:sizeof(uint8_t)];
		messageType &= 0x0F; // messageType is actually the second nibble in byte 5
		
		switch (messageType) {
			case BRMessageTypeHostProtocolVersion:
				DLog(DLogLevelTrace, @"BRMessageTypeHostProtocolVersion(%d)", port);
				// something
				break;
				
			case BRMessageTypeSettingRequest:
				DLog(DLogLevelTrace, @"BRMessageTypeSettingRequest(%d)", port);
				// something
				break;
				
			case BRMessageTypeSettingResultSuccess: {
				BRSettingResponseID deckardID;
				NSData *deckardIDData = [data subdataWithRange:NSMakeRange(6, sizeof(uint16_t))];
				[deckardIDData getBytes:&deckardID length:sizeof(uint16_t)];
				deckardID = ntohs(deckardID);
				
				Class class = nil;
				
				switch (deckardID) {
#ifndef GENESIS
					case BRSettingResponseIDWearingState:
						class = [BRWearingStateSettingResponse class];
						break;
#endif
						
					case BRSettingResponseIDSignalStrength:
						class = [BRSignalStrengthSettingResponse class];
						break;
						
					case BRSettingResponseIDDeviceInfo:
						class = [BRDeviceInfoSettingResponse class];
						break;
						
					case BRSettingResponseIDGenesGUID:
						class = [BRGenesGUIDSettingResponse class];
						break;
						
					case BRSettingResponseIDProductName:
						class = [BRProductNameSettingResponse class];
						break;
						
					case BRSettingResponseIDConnectionStatus:
						class = [BRConnectionStatusSettingResponse class];
						break;
						
					case BRSettingResponseIDHeadsetCallStatus:
						class = [BRHeadsetCallStatusSettingResponse class];
						break;
						
					case BRSettingResponseIDSeaviceData: {
						BRServiceID serviceID;
						NSData *serviceIDData = [data subdataWithRange:NSMakeRange(8, sizeof(uint16_t))];
						[serviceIDData getBytes:&serviceID length:sizeof(uint16_t)];
						serviceID = ntohs(serviceID);
						
						switch (serviceID) {
							case BRServiceIDOrientationTracking:
								class = [BROrientationTrackingSettingResponse class];
								break;
							case BRServiceIDTaps:
								class = [BRTapsSettingResponse class];
								break;
							case BRServiceIDFreeFall:
								class = [BRFreeFallSettingResponse class];
								break;
							case BRServiceIDPedometer:
								class = [BRPedometerSettingResponse class];
								break;
							case BRServiceIDMagCal:
								class = [BRMagnetometerCalStatusSettingResponse class];
								break;
							case BRServiceIDGyroCal:
								class = [BRGyroscopeCalStatusSettingResponse class];
								break;
							default:
								DLog(DLogLevelError, @"Error: unknown service ID 0x%02X", serviceID);
								break;
						}
						break; }
						
					default:
						//NSLog(@"Error: unknown Deckard setting 0x%04X", deckardID);
						if ([self.delegate respondsToSelector:@selector(BRDevice:didReceiveUnknownMessage:)]) {
							[self.delegate BRDevice:self didReceiveUnknownMessage:[BRIncomingMessage messageWithData:data]];
						}
						break;
				}
				
				if (class) {
					//[self.delegate BRDevice:self didReceiveSettingResponse:[class settingResponseWithData:data]];
					
					if (destinationDevice == self) {
						[self.delegate BRDevice:self didReceiveSettingResponse:[class settingResponseWithData:data]];
					}
					else {
						[(BRRemoteDevice *)destinationDevice BRDevice:destinationDevice didReceiveSettingResponse:[class settingResponseWithData:data]];
					}
				}
				break; }
				
			case BRMessageTypeSettingResultException:
			case BRMessageTypeCommandResultException: {
				DLog(DLogLevelError, @"***** EXCEPTION(%d) *****", port);
				
				//            BRExceptionID exceptionID;
				//            NSData *exceptionIDData = [data subdataWithRange:NSMakeRange(10, sizeof(uint16_t))];
				//            [exceptionIDData getBytes:&exceptionID length:sizeof(uint16_t)];
				//            exceptionID = ntohs(exceptionID);
				//            
				//            Class class = nil;
				//            
				//            switch (exceptionID) {
				//                case BRExceptionIDDeviceNotReady:
				//                    class = [BRDeviceNotReadyException class];
				//                    break;
				//                case BRExceptionIDIllegalValue:
				//                    class = [BRIllegalValueException class];
				//                    break;
				//                default:
				//                    NSLog(@"Error: unknown Deckard exception 0x%04X", exceptionID);
				//                    break;
				//            }
				//            
				//            if (class) {
				//                [self.delegate BRDevice:self didRaiseException:[class exceptionWithData:data]];
				//            }
				break; }
				
			case BRMessageTypeCommand:
				// something
				break;
				
			case BRMessageTypeCommandResultSuccess:
				DLog(DLogLevelTrace, @"BRMessageTypeCommandResultSuccess(%d)", port);
				break;
				//        case BRMessageTypeCommandResultException:
				//            NSLog(@"***** COMMAND EXCEPTION *****");
				//            break;
				
			case BRMessageTypeDeviceProtocolVersion: {
				BRDeviceProtocolVersionMessage *protocolVersionMessage = (BRDeviceProtocolVersionMessage *)[BRDeviceProtocolVersionMessage messageWithData:data];
				DLog(DLogLevelTrace, @"BRMessageTypeDeviceProtocolVersion(%d): %@", port, protocolVersionMessage);
				destinationDevice.state = BRDeviceStateAwaitingMetadata;
				
				break; }
				
			case BRMessageTypeMetadata: {
				BRMetadataMessage *metadata = (BRMetadataMessage *)[BRMetadataMessage messageWithData:data];
				
				// if port==0, it's our metadata
				// if other, find remoteDevice and deliver accordingly
				
				//if ([metadata.address integerValue] == 0) {
				if (destinationDevice == self) {
					self.commands = metadata.commands;
					self.settings = metadata.settings;
					self.events = metadata.events;
					self.state = BRDeviceStateConnected;
					[self.delegate BRDeviceDidConnect:self];
					//[self.delegate BRDevice:self didReceiveMetadata:metadata];
				}
				else {
					[(BRRemoteDevice *)destinationDevice BRDevice:self didReceiveMetadata:metadata];
				}
				break; }
				
			case BRMessageTypeEvent: {
				DLog(DLogLevelTrace, @"BRMessageTypeEvent(%d)", port);
				
				BREventID deckardID;
				NSData *deckardIDData = [data subdataWithRange:NSMakeRange(6, sizeof(uint16_t))];
				[deckardIDData getBytes:&deckardID length:sizeof(uint16_t)];
				deckardID = ntohs(deckardID);
				
				Class class = nil;
				
				switch (deckardID) {
						
					case BREventIDDeviceConnected: {
						// don't send "normal" events for this.
						//class = [BRDeviceConnectedEvent class];
						
						BRDeviceConnectedEvent *event = (BRDeviceConnectedEvent *)[BRDeviceConnectedEvent eventWithData:data];
						BRRemoteDevice *remoteDevice = [BRRemoteDevice deviceWithParent:self port:event.port];
						((NSMutableDictionary *)self.remoteDevices)[@(event.port)] = remoteDevice;
						[self.delegate BRDevice:self didFindRemoteDevice:remoteDevice];
						
						break; }
						
					case BREventIDDeviceDisconnected: {
						//class = [BRDeviceDisconnectedEvent class];
						
						BRDeviceDisconnectedEvent *event = (BRDeviceDisconnectedEvent *)[BRDeviceConnectedEvent eventWithData:data];
						BRRemoteDevice *remoteDevice = self.remoteDevices[@(event.port)];
						[((NSMutableDictionary *)self.remoteDevices) removeObjectForKey:@(event.port)];
						[remoteDevice BRDeviceDidDisconnect:remoteDevice];
						
						break; }
						
					case BREventIDWearingStateChanged:
						class = [BRWearingStateEvent class];
						break;
						
					case BREventIDSignalStrength:
						class = [BRSignalStrengthEvent class];
						break;
						
					case BREventIDServiceDataChanged: {
						uint16_t serviceID;
						NSData *serviceIDIDData = [data subdataWithRange:NSMakeRange(8, sizeof(uint16_t))];
						[serviceIDIDData getBytes:&serviceID length:sizeof(uint16_t)];
						serviceID = ntohs(serviceID);
						
						switch (serviceID) {
							case BRServiceIDOrientationTracking:
								class = [BROrientationTrackingEvent class];
								break;
							case BRServiceIDTaps:
								class = [BRTapsEvent class];
								break;
							case BRServiceIDFreeFall:
								class = [BRFreeFallEvent class];
								break;
							case BRServiceIDPedometer:
								class = [BRPedometerEvent class];
								break;
							case BRServiceIDMagCal:
								class = [BRMagnetometerCalStatusEvent class];
								break;
							case BRServiceIDGyroCal:
								class = [BRGyroscopeCalStatusEvent class];
								break;
							default:
								class = [BRSubscribedServiceDataEvent class];
								break;
						}
						break; }
						
					case BREventIDServiceSubscriptionChanged:
						class = [BRServiceSubscriptionChangedEvent class];
						break;
						
					case BREventIDCustomButton:
						class = [BRCustomButtonEvent class];
						break;
						
					case BREventIDHeadsetCallStatus:
						class = [BRHeadsetCallStatusEvent class];
						break;
						
#ifdef BANGLE
					case BREventIDApplicationActionResult:
						class = [BRApplicationActionResultEvent class];
						break;
#endif
						
					default:
						//NSLog(@"Error: unknown Deckard event 0x%04X", deckardID);
						if ([self.delegate respondsToSelector:@selector(BRDevice:didReceiveUnknownMessage:)]) {
							[self.delegate BRDevice:self didReceiveUnknownMessage:[BRIncomingMessage messageWithData:data]];
						}
						break;
                }
				
				if (class) {
					if (destinationDevice == self) {
						[self.delegate BRDevice:self didReceiveEvent:[class eventWithData:data]];
					}
					else {
						[(BRRemoteDevice *)destinationDevice BRDevice:destinationDevice didReceiveEvent:[class eventWithData:data]];
					}
				}
				
				break; }
				
			case BRMessageTypeCloseSession:
				DLog(DLogLevelTrace, @"BRMessageTypeCloseSession(%d)", port);
				break;
				
			case BRMessageTypeProtocolVersionRejection:
				DLog(DLogLevelTrace, @"BRMessageTypeProtocolVersionRejection(%d)", port);;
				break;
				
			case BRMessageTypeConnectionChangeEvent:
				DLog(DLogLevelTrace, @"BRMessageTypeConnectionChangeEvent(%d)", port);
				break;
				
			default:
				DLog(DLogLevelWarn, @"Error: unknown message type 0x%01X, port %d", messageType, port);
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

#pragma mark - IOBluetoothRFCOMMChannelDelegate

#ifdef TARGET_OSX
- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel *)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength;
{
    NSData *data = [NSData dataWithBytes:dataPointer length:dataLength];
    [self parseIncomingMessage:data];
}

- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel *)rfcommChannel status:(IOReturn)error
{
    DLog(DLogLevelTrace, @"rfcommChannelOpenComplete: %@, status: %d", rfcommChannel, error);
	
	if (!rfcommChannel.isOpen) {
		// when an invalid BT address is supplied, error is 4. not sure where this comes from.
		[self.delegate BRDevice:self didFailConnectWithError:error];
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
	
//	self.channelOpened = NO;
//	self.isConnected = NO;
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
        //self.channelOpened = YES;
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
	
//	self.state = BRDeviceStateDisconnected;
//	
//	for (NSNumber *port in self.remoteDevices) {
//		id destinationDevice = self.remoteDevices[port];
//		[destinationDevice BRDeviceDidDisconnect:self];
//	}
//    [self.delegate BRDeviceDidDisconnect:self];
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
		
		uint8_t buf[4096*3]; // maximum deckard message size (with address type 1) x 3.
		NSUInteger len = [[self.session inputStream] read:buf maxLength:4096*3];
		
		NSData *data = [NSData dataWithBytes:buf length:len];
		
		//NSLog(@"MFI packet: %@", [data hexStringWithSpaceEvery:2]);
		
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

//- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
//{
//	switch (streamEvent) {
//        case NSStreamEventErrorOccurred: {
//            NSError *error = [theStream streamError];
//            NSString *errorMessage = [NSString stringWithFormat:@"%@ (code %d)", [error localizedDescription], [error code]];
//            NSLog(@"StreamEventError %@", errorMessage);
//            break; }
//            
//        case NSStreamEventNone:
//            NSLog(@"NSStreamEventNone");
//            break;
//            
//        case NSStreamEventEndEncountered:
//            NSLog(@"NSStreamEventEndEncountered");
//            break;
//            
//        case NSStreamEventHasBytesAvailable: {
//			NSLog(@"NSStreamEventHasBytesAvailable:");
//			
//			uint8_t buf[4096*3]; // maximum deckard message size (with address type 1) x 3.
//			NSUInteger len = [[self.session inputStream] read:buf maxLength:4096*3];
//
//			NSData *data = [NSData dataWithBytes:buf length:len];
//			
//			NSLog(@"MFI packet: %@", [data hexStringWithSpaceEvery:2]);
//			
//			// since the "MFI prefix" is added to every BUFFER, not every MESSAGE, from it for each buffer
//			data = [data subdataWithRange:NSMakeRange(2, [data length]-2)];
//			
//			[self.accumulatedInputData appendData:data];
//			[self checkAccumulatedInputData];
//			//[self parseIncomingMessage:data];
//			
//            break; }
//			
//		case NSStreamEventOpenCompleted:
//			NSLog(@"NSStreamEventOpenCompleted");
//			self.accumulatedInputData = [NSMutableData data];
//			break;
//			
//		case NSStreamEventHasSpaceAvailable:
//			NSLog(@"NSStreamEventHasSpaceAvailable");
//			
//			if (!self.streamOpened) {
//				self.streamOpened = YES;
//				if (self.state==BRDeviceStateOpeningEASession) {
//					self.state = BRDeviceStateHostVersionNegotiating;
//					BRHostVersionNegotiateMessage *message = (BRHostVersionNegotiateMessage *)[BRHostVersionNegotiateMessage messageWithMinimumVersion:1 maximumVersion:1];
//					[self sendMessage:message];
//				}
//			}
//		default:
//			NSLog(@"********************************************* UNKNOWN STREAM EVENT *********************************************");
//			break;
//    }
//}
#endif

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[BRDevice class]]) {
#ifdef TARGET_OSX
		[((BRDevice *)object).bluetoothAddress isEqualToString:self.bluetoothAddress];
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
    return [NSString stringWithFormat:@"<BRDevice %p> bluetoothAddress=%@, isConnected=%@, commands=(%lu), settings=(%lu), events=(%lu), remoteDevices=(%d), delegate=%@",
            self, self.bluetoothAddress, (self.isConnected ? @"YES" : @"NO"), (unsigned long)[self.commands count], (unsigned long)[self.settings count], 
			(unsigned long)[self.events count], [self.remoteDevices count], self.delegate];
#endif
#ifdef TARGET_IOS
	return [NSString stringWithFormat:@"<BRDevice %p> accessory=%@, isConnected=%@, commands=(%lu), settings=(%lu), events=(%lu), remoteDevices=(%d), delegate=%@",
            self, self.accessory.name, (self.isConnected ? @"YES" : @"NO"), (unsigned long)[self.commands count], (unsigned long)[self.settings count], 
			(unsigned long)[self.events count], [self.remoteDevices count], self.delegate];
#endif
}

@end
