//
//  BRCustomDeviceStatusSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCustomDeviceStatusSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRCustomDeviceStatusSettingRequest

#pragma BRSettingRequest

+ (BRCustomDeviceStatusSettingRequest *)request
{
	BRCustomDeviceStatusSettingRequest *instance = [[BRCustomDeviceStatusSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CUSTOM_DEVICE_STATUS_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[

			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCustomDeviceStatusSettingRequest %p>",
            self];
}

@end
