//
//  BRRemoteDevice.m
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRemoteDevice.h"
#import "BRDevice_Private.h"
#import "BRMessage_Private.h"
#import "BRHostVersionNegotiateMessage.h"
#import "NSData+HexStrings.h"
#import "BRMetadataMessage.h"
#ifdef TARGET_IOS
#import <ExternalAccessory/ExternalAccessory.h>
#endif

//typedef enum {
//    BRRemoteDeviceStateDisconnected,
//    BRRemoteDeviceStateHostVersionNegotiating,
//	BRRemoteDeviceStateConnected
//} BRDeviceState;


@interface BRRemoteDevice ()

- (uint32_t)address;

@property(nonatomic,strong,readwrite)	BRDevice		*parent;
@property(nonatomic,readwrite)			uint8_t			port;


//@property(nonatomic,assign,readwrite)   BOOL			isConnected;
//@property(nonatomic,assign)             BRDeviceState	state;
//@property(nonatomic,strong,readwrite)   BRMetadata		*metadata;

@end


@implementation BRRemoteDevice

#pragma mark - Public

+ (BRRemoteDevice *)deviceWithParent:(BRDevice *)parent port:(uint8_t)port
{
	BRRemoteDevice *device = [[BRRemoteDevice alloc] init];
	device.parent = parent;
	device.port = port;
#ifdef TARGET_OSX
	device.bluetoothAddress = parent.bluetoothAddress;
#endif
#ifdef TARGET_IOS
	device.accessory = parent.accessory;
#endif
	return device;
}

- (void)openConnection
{
	if (self.state==BRDeviceStateDisconnected) {
		self.state = BRDeviceStateHostVersionNegotiating;
		BRHostVersionNegotiateMessage *message = (BRHostVersionNegotiateMessage *)[BRHostVersionNegotiateMessage messageWithMinimumVersion:1 maximumVersion:1];
		[self sendMessage:message];
	}
}

- (void)sendMessage:(BRMessage *)message
{
	// calculate the address for the message
	
	message.address = [NSString stringWithFormat:@"%d000000", self.port];
    [self.parent sendMessage:message];
}

#pragma mark - Private

- (void)BRDevice:(BRDevice *)device didReceiveMetadata:(BRMetadataMessage *)metadata
{
	self.commands = metadata.commands;
	self.settings = metadata.settings;
	self.events = metadata.events;
	self.isConnected = YES;
	[self.delegate BRDeviceDidConnect:self];
}

#pragma mark - BRDeviceDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
	self.isConnected = YES;
	[self.delegate BRDeviceDidConnect:self];
}

- (void)BRDeviceDidDisconnect:(BRDevice *)device
{
	self.isConnected = NO;
	[self.delegate BRDeviceDidDisconnect:self];
}

- (void)BRDevice:(BRDevice *)device didFailConnectWithError:(int)ioBTError
{
	self.isConnected = NO;
	[self.delegate BRDevice:self didFailConnectWithError:ioBTError];
}

//- (void)BRDevice:(BRDevice *)device didReceiveMetadata:(BRMetadata *)metadata
//{
//	self.metadata = metadata;
//	[self.delegate BRDevice:self didReceiveMetadata:metadata];
//}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
	[self.delegate BRDevice:self didReceiveEvent:event];
}

- (void)BRDevice:(BRDevice *)device didReceiveSettingResponse:(BRSettingResponse *)settingResponse
{
	[self.delegate BRDevice:self didReceiveSettingResponse:settingResponse];
}

- (void)BRDevice:(BRDevice *)device didRaiseException:(BRException *)exception
{
	[self.delegate BRDevice:self didRaiseException:exception];
}

- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data
{
	[self.delegate BRDevice:self willSendData:data];
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
	[self.delegate BRDevice:self didReceiveData:data];
}

#pragma mark - NSObject


- (NSString *)description
{
#ifdef TARGET_OSX
    return [NSString stringWithFormat:@"<BRDevice %p> bluetoothAddress=%@, port=%d, parent=%p, isConnected=%@, commands=(%lu), settings=(%lu), events=(%lu), delegate=%@",
            self, self.bluetoothAddress, self.port, self.parent, (self.isConnected ? @"YES" : @"NO"), (unsigned long)[self.commands count], 
			(unsigned long)[self.settings count], (unsigned long)[self.events count], self.remoteDevices];
#endif
#ifdef TARGET_IOS
	return [NSString stringWithFormat:@"<BRDevice %p> accessory=%@, port=%d, parent=%p, isConnected=%@, commands=(%lu), settings=(%lu), events=(%lu), delegate=%@",
            self, self.accessory.name, self.port, self.parent, (self.isConnected ? @"YES" : @"NO"), (unsigned long)[self.commands count], 
			(unsigned long)[self.settings count], (unsigned long)[self.events count], self.remoteDevices];
#endif
}

@end
