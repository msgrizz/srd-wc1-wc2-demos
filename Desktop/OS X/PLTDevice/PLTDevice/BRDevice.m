//
//  BRDevice.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDevice.h"
#import <IOBluetooth/Bluetooth.h>
#import <IOBluetooth/IOBluetoothUserLib.h>
#import <IOBluetooth/IOBluetooth.h>
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


typedef enum {
    BRDeviceStateDisconnected,
    BRDeviceStateOpeningRFCOMMChannel,
    BRDeviceStateOpeningLocalPortConnection,
    BRDeviceStateOpeningSensorsPortConnection
    
    //BRDeviceStateAwaitingMessageResponse
} BRDeviceState;


@interface BRDevice ()

- (void)openLocalConnection;
- (void)openSensorsConnection;
- (void)parseIncomingData:(NSData *)data;

@property(nonatomic,assign,readwrite)   BOOL                        isConnected;
@property(nonatomic,assign)             BOOL                        channelOpened;
@property(nonatomic,strong,readwrite)   NSString                    *BTAddress;
@property(nonatomic,assign)             BRDeviceState               state;
@property(nonatomic,strong)             IOBluetoothRFCOMMChannel    *RFCOMMChannel;

@end


@implementation BRDevice


#pragma mark - Public

+ (BRDevice *)deviceWithAddress:(NSString *)BTAddress
{
    BRDevice *controller = [[BRDevice alloc] init];
    controller.BTAddress = BTAddress;
    return controller;
}

- (void)openConnection
{
    NSLog(@"Opening connection to device at address %@...", self.BTAddress);
    
    self.state = BRDeviceStateOpeningRFCOMMChannel;
    
    IOBluetoothDevice *device = [IOBluetoothDevice deviceWithAddressString:self.BTAddress];
    IOBluetoothRFCOMMChannel *RFCOMMChannel;
    IOReturn error = [device openRFCOMMChannelAsync:&RFCOMMChannel withChannelID:5 delegate:self];
    self.RFCOMMChannel = RFCOMMChannel;
    if (error != kIOReturnSuccess) {
        NSLog(@"Error opening RFCOMM channel: %d", error);
        self.state = BRDeviceStateDisconnected;
        [self.delegate BRDevice:self didFailConnectToHTDeviceWithError:error];
    }
}

- (void)sendMessage:(BRMessage *)message
{
    NSLog(@"--> %@", [message.data hexStringWithSpaceEvery:2]);
    //self.state = BRDeviceStateAwaitingMessageResponse;
    [self.RFCOMMChannel writeAsync:(void *)[message.data bytes] length:[message.data length] refcon:nil];
}

#pragma mark - Private

- (void)openLocalConnection
{
    NSLog(@"Opening local port connection...");
    
    self.state = BRDeviceStateOpeningLocalPortConnection;
    
    NSString *hexString = @"100700000001010101";
    NSData *data = [NSData dataWithHexString:hexString];
    NSLog(@"--> %@", [data hexStringWithSpaceEvery:2]);
    [self.RFCOMMChannel writeAsync:(void *)[data bytes] length:[data length] refcon:nil];
}

- (void)openSensorsConnection
{
    NSLog(@"Opening sensors port connection...");
    
    self.state = BRDeviceStateOpeningSensorsPortConnection;
    
    NSString *hexString = @"100750000001010101";
    NSData *data = [NSData dataWithHexString:hexString];
    NSLog(@"--> %@", [data hexStringWithSpaceEvery:2]);
    [self.RFCOMMChannel writeAsync:(void *)[data bytes] length:[data length] refcon:nil];
}

- (void)parseIncomingData:(NSData *)data
{
    uint8_t messageType;
    NSData *messageTypeData = [data subdataWithRange:NSMakeRange(5, sizeof(uint8_t))];
    [messageTypeData getBytes:&messageType length:sizeof(uint8_t)];
    messageType &= 0x0F; // messageType is actually the second nibble in byte 5
    
    switch (messageType) {
        case BRMessageTypeHostProtocolVersion:
            // something
            break;
            
        case BRMessageTypeGetSetting:
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
                [self.delegate BRDevice:self didReceiveSettingResponse:[class settingResponseWithData:data]];
            }
            break; }
        case BRMessageTypeSettingResultException:
        case BRMessageTypeCommandResultException: {
            NSLog(@"***** EXCEPTION *****");
            
            BRExceptionID exceptionID;
            NSData *exceptionIDData = [data subdataWithRange:NSMakeRange(10, sizeof(uint16_t))];
            [exceptionIDData getBytes:&exceptionID length:sizeof(uint16_t)];
            exceptionID = ntohs(exceptionID);
            
            Class class = nil;
            
            switch (exceptionID) {
                case BRExceptionIDDeviceNotReady:
                    class = [BRDeviceNotReadyException class];
                    break;
                case BRExceptionIDIllegalValue:
                    class = [BRIllegalValueException class];
                    break;
                default:
                    NSLog(@"Error: unknown Deckard exception 0x%04X", exceptionID);
                    break;
            }
            
            if (class) {
                [self.delegate BRDevice:self didRaiseException:[class exceptionWithData:data]];
            }
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
        case BRMessageTypeDeviceProtocolVersion:
            NSLog(@"BRMessageTypeDeviceProtocolVersion");
            break;
        case BRMessageTypeMetadata: {
            uint8_t port;
            NSData *portData = [data subdataWithRange:NSMakeRange(2, sizeof(uint8_t))];
            [portData getBytes:&port length:sizeof(uint8_t)];
            if (port==0) {
                NSLog(@"Connected to local device!");
                [self openSensorsConnection];
            }
            else if (port==5) {
                NSLog(@"Connected to sensors device!");
                [self.delegate BRDeviceDidConnectToHTDevice:self];
            }
            break; }
            
        case BRMessageTypeEvent: {
            BREventID deckardID;
            NSData *deckardIDData = [data subdataWithRange:NSMakeRange(6, sizeof(uint16_t))];
            [deckardIDData getBytes:&deckardID length:sizeof(uint16_t)];
            deckardID = ntohs(deckardID);
            
            Class class = nil;
            
            switch (deckardID) {
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
                    
                case BREventIDDeviceConnected:
                    class = [BRDeviceConnectedEvent class];
                    break;
                    
                case BREventIDDeviceDisconnected:
                    class = [BRDeviceDisconnectedEvent class];
                    break;
                    
                default:
                    NSLog(@"Error: unknown Deckard event 0x%04X", deckardID);
                    break;
                }
            
            if (class) {
                [self.delegate BRDevice:self didReceiveEvent:[class eventWithData:data]];
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

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength;
{
    NSData *data = [NSData dataWithBytes:dataPointer length:dataLength];
    NSLog(@"<-- %@", [data hexStringWithSpaceEvery:2]);
    
    [self parseIncomingData:data];
}

- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error
{
    NSLog(@"rfcommChannelOpenComplete: %@, status: %d", rfcommChannel, error);
}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NSLog(@"rfcommChannelClosed:");
    self.state = BRDeviceStateDisconnected;
    [self.delegate BRDeviceDidDisconnectFromHTDevice:self];
}

- (void)rfcommChannelControlSignalsChanged:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NSLog(@"rfcommChannelControlSignalsChanged:");
}

- (void)rfcommChannelFlowControlChanged:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NSLog(@"rfcommChannelFlowControlChanged: %d", [rfcommChannel getMTU]);
}

- (void)rfcommChannelWriteComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel refcon:(void*)refcon status:(IOReturn)error
{
    NSLog(@"rfcommChannelWriteComplete: %d", error);
}

- (void)rfcommChannelQueueSpaceAvailable:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NSLog(@"rfcommChannelQueueSpaceAvailable:");
    
    if (!self.channelOpened) {
        self.channelOpened = YES;
        if (self.state==BRDeviceStateOpeningRFCOMMChannel) {
            [self openLocalConnection];
        }
    }
}

@end
