//
//  BRA2DPIsEnabledSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRA2DPIsEnabledSettingRequest.h"
#import "BRMessage_Private.h"




@implementation BRA2DPIsEnabledSettingRequest

#pragma BRSettingRequest

+ (BRA2DPIsEnabledSettingRequest *)request
{
	BRA2DPIsEnabledSettingRequest *instance = [[BRA2DPIsEnabledSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_A2DP_IS_ENABLED_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRA2DPIsEnabledSettingRequest %p>",
            self];
}

@end
