//
//  BRConfigureDevicePowerStateCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRConfigureDevicePowerStateCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureDevicePowerStateCommand

#pragma mark - Public

+ (BRConfigureDevicePowerStateCommand *)commandWithDeviceState:(uint8_t)deviceState
{
	BRConfigureDevicePowerStateCommand *instance = [[BRConfigureDevicePowerStateCommand alloc] init];
	instance.deviceState = deviceState;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_DEVICE_POWER_STATE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"deviceState", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureDevicePowerStateCommand %p> deviceState=0x%02X",
            self, self.deviceState];
}

@end
