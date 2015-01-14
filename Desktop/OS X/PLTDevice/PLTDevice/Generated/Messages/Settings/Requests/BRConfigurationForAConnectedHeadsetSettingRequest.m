//
//  BRConfigurationForAConnectedHeadsetSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigurationForAConnectedHeadsetSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRConfigurationForAConnectedHeadsetSettingRequest

#pragma BRSettingRequest

+ (BRConfigurationForAConnectedHeadsetSettingRequest *)request
{
	BRConfigurationForAConnectedHeadsetSettingRequest *instance = [[BRConfigurationForAConnectedHeadsetSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURATION_FOR_A_CONNECTED_HEADSET_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRConfigurationForAConnectedHeadsetSettingRequest %p>",
            self];
}

@end
