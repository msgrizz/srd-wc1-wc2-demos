//
//  BRFindHeadsetLEDAlertStatusSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRFindHeadsetLEDAlertStatusSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRFindHeadsetLEDAlertStatusSettingRequest

#pragma BRSettingRequest

+ (BRFindHeadsetLEDAlertStatusSettingRequest *)request
{
	BRFindHeadsetLEDAlertStatusSettingRequest *instance = [[BRFindHeadsetLEDAlertStatusSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FIND_HEADSET_LED_ALERT_STATUS_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRFindHeadsetLEDAlertStatusSettingRequest %p>",
            self];
}

@end
