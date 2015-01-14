//
//  BRBatteryInfoSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRBatteryInfoSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRBatteryInfoSettingRequest

#pragma BRSettingRequest

+ (BRBatteryInfoSettingRequest *)request
{
	BRBatteryInfoSettingRequest *instance = [[BRBatteryInfoSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BATTERY_INFO_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRBatteryInfoSettingRequest %p>",
            self];
}

@end
