//
//  BRDevice.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

//#import "Configuration.h"

#import "BRDevice.h"
#import "BRDevice_Private.h"
#import "BRMessage_Private.h"
#import "BRIncomingMessage_Private.h"
#import "BROutgoingMessage_Private.h"
#import "BRRemoteDevice_Private.h"
#import "BRRemoteDevice.h"
#import "BRMessage.h"
#import "BRSubscribeToServiceCommand.h"
#import "NSData+HexStrings.h"
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
#import "NSArray+PrettyPrint.h"
#import "BRCloseSessionMessage.h"
#import "BRDeviceProtocolVersionMessage.h"
#import "BRGenesGUIDSettingResponse.h"
#import "BRProductNameSettingResponse.h"

//#if TARGET_OSX
#import <IOBluetooth/Bluetooth.h>
#import <IOBluetooth/IOBluetoothUserLib.h>
#import <IOBluetooth/IOBluetooth.h>
//#else
//// iOS external accessory stuff
//#endif


@interface BRDevice ()

- (void)parseIncomingData:(NSData *)data;

@property(nonatomic,assign)             BOOL                        channelOpened;
@property(nonatomic,strong)             IOBluetoothRFCOMMChannel    *RFCOMMChannel;
@property(nonatomic,strong,readwrite)	NSMutableDictionary			*remoteDevices;

@end


@implementation BRDevice


#pragma mark - Public

+ (BRDevice *)deviceWithAddress:(NSString *)bluetoothAddress
{
    BRDevice *device = [[BRDevice alloc] init];
    device.bluetoothAddress = bluetoothAddress;
    return device;
}

- (void)openConnection
{
    NSLog(@"Opening connection to device at address %@...", self.bluetoothAddress);
    
	if (!self.isConnected) {
		self.state = BRDeviceStateOpeningRFCOMMChannel;
		self.remoteDevices = [NSMutableDictionary dictionary];
		
		IOBluetoothDevice *device = [IOBluetoothDevice deviceWithAddressString:self.bluetoothAddress];
		IOBluetoothRFCOMMChannel *RFCOMMChannel;
		self.channelOpened = NO;
		IOReturn error = [device openRFCOMMChannelAsync:&RFCOMMChannel withChannelID:5 delegate:self];
		self.RFCOMMChannel = RFCOMMChannel;
		if (error != kIOReturnSuccess) {
			NSLog(@"Error opening RFCOMM channel: %d", error);
			self.state = BRDeviceStateDisconnected;
			[self.delegate BRDevice:self didFailConnectWithError:error];
		}
	}
	else {
		NSLog(@"Already connected!");
	}
}

- (void)closeConnection
{
    NSLog(@"Closing connection (%@)...", self.bluetoothAddress);
	
#warning check disconnect remote devices
    
    BRCloseSessionMessage *message = (BRCloseSessionMessage *)[BRCloseSessionMessage message];
    [self sendMessage:message];
    
    [self.RFCOMMChannel closeChannel];
	
	self.isConnected = NO;
}

- (void)sendMessage:(BRMessage *)message
{
	NSData *messageData = message.data; // message.data computes on each call...
	
	if ([message.address integerValue] == 0) {
		[self.delegate BRDevice:self willSendData:messageData];
	}
	else {
		NSString *portString = [message.address substringToIndex:1];
		uint8_t port = [portString integerValue];
		BRRemoteDevice *remoteDevice = self.remoteDevices[@(port)];
		[remoteDevice BRDevice:self willSendData:messageData];
	}
	
    [self.RFCOMMChannel writeAsync:(void *)[messageData bytes] length:[messageData length] refcon:nil];
}

#pragma mark - Private

- (void)parseIncomingData:(NSData *)data
{
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
			NSLog(@"BRMessageTypeHostProtocolVersion");
            // something
            break;
            
        case BRMessageTypeSettingRequest:
			NSLog(@"BRMessageTypeSettingRequest");
            // something
            break;
            
        case BRMessageTypeSettingResultSuccess: {
            BRSettingResponseID deckardID;
            NSData *deckardIDData = [data subdataWithRange:NSMakeRange(6, sizeof(uint16_t))];
            [deckardIDData getBytes:&deckardID length:sizeof(uint16_t)];
            deckardID = ntohs(deckardID);
            
            Class class = nil;
            
            switch (deckardID) {
                case BRSettingResponseIDWearingState:
                    class = [BRWearingStateSettingResponse class];
                    break;
                    
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
                            NSLog(@"Error: unknown service ID 0x%02X", serviceID);
                            break;
                    }
                    break; }
                    
                default:
                    NSLog(@"Error: unknown Deckard setting 0x%04X", deckardID);
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
            NSLog(@"***** EXCEPTION *****");
            
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
            NSLog(@"BRMessageTypeCommandResultSuccess");
            break;
//        case BRMessageTypeCommandResultException:
//            NSLog(@"***** COMMAND EXCEPTION *****");
//            break;
			
        case BRMessageTypeDeviceProtocolVersion: {
			BRDeviceProtocolVersionMessage *protocolVersionMessage = (BRDeviceProtocolVersionMessage *)[BRDeviceProtocolVersionMessage messageWithData:data];
            NSLog(@"BRMessageTypeDeviceProtocolVersion: %@", protocolVersionMessage);
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
				self.isConnected = YES;
				[self.delegate BRDeviceDidConnect:self];
				//[self.delegate BRDevice:self didReceiveMetadata:metadata];
			}
			else {
				[(BRRemoteDevice *)destinationDevice BRDevice:self didReceiveMetadata:metadata];
            }
            break; }
            
        case BRMessageTypeEvent: {
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
                            NSLog(@"Error: unknown service ID 0x%02X", serviceID);
                            break;
                    }
                    break; }
                    
                case BREventIDServiceSubscriptionChanged:
                    class = [BRServiceSubscriptionChangedEvent class];
                    break;
                    
                default:
                    NSLog(@"Error: unknown Deckard event 0x%04X", deckardID);
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
            NSLog(@"BRMessageTypeCloseSession");
            break;
            
        case BRMessageTypeProtocolVersionRejection:
            NSLog(@"BRMessageTypeProtocolVersionRejection");
            break;
            
        case BRMessageTypeConnectionChangeEvent:
            NSLog(@"BRMessageTypeConnectionChangeEvent");
            break;
            
        default:
            NSLog(@"Error: unknown message type 0x%01X", messageType);
            break;
    }
}

#pragma mark - IOBluetoothRFCOMMChannelDelegate

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel *)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength;
{
    NSData *data = [NSData dataWithBytes:dataPointer length:dataLength];
    //NSLog(@"<-- %@", [data hexStringWithSpaceEvery:2]);
    [self.delegate BRDevice:self didReceiveData:data];
    
    [self parseIncomingData:data];
}

- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel *)rfcommChannel status:(IOReturn)error
{
    NSLog(@"rfcommChannelOpenComplete: %@, status: %d", rfcommChannel, error);
	
	if (!rfcommChannel.isOpen) {
		// when an invalid BT address is supplied, error is 4. not sure where this comes from.
		[self.delegate BRDevice:self didFailConnectWithError:error];
	}
}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
    NSLog(@"rfcommChannelClosed:");
    self.state = BRDeviceStateDisconnected;
    [self.delegate BRDeviceDidDisconnect:self];
	self.channelOpened = NO;
	self.isConnected = NO;
}

- (void)rfcommChannelControlSignalsChanged:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
    NSLog(@"rfcommChannelControlSignalsChanged:");
}

- (void)rfcommChannelFlowControlChanged:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
    NSLog(@"rfcommChannelFlowControlChanged: %d", [rfcommChannel getMTU]);
}

- (void)rfcommChannelWriteComplete:(IOBluetoothRFCOMMChannel *)rfcommChannel refcon:(void*)refcon status:(IOReturn)error
{
    NSLog(@"rfcommChannelWriteComplete: %d", error);
}

- (void)rfcommChannelQueueSpaceAvailable:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
    NSLog(@"rfcommChannelQueueSpaceAvailable:");
    
    if (!self.channelOpened) {
        self.channelOpened = YES;
        if (self.state==BRDeviceStateOpeningRFCOMMChannel) {
            self.state = BRDeviceStateHostVersionNegotiating;
			//BRHostVersionNegotiateMessage *message = [BRHostVersionNegotiateMessage messageWithAddress:0x0000000];
			BRHostVersionNegotiateMessage *message = (BRHostVersionNegotiateMessage *)[BRHostVersionNegotiateMessage messageWithMinimumVersion:1 maximumVersion:1];
			[self sendMessage:message];
        }
    }
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDevice %p> bluetoothAddress=%@, isConnected=%@, commands=(%lu), settings=(%lu), events=(%lu), remoteDevices=(%d), delegate=%@",
            self, self.bluetoothAddress, (self.isConnected ? @"YES" : @"NO"), (unsigned long)[self.commands count], (unsigned long)[self.settings count], (unsigned long)[self.events count], [self.remoteDevices count], self.delegate];
}

@end
