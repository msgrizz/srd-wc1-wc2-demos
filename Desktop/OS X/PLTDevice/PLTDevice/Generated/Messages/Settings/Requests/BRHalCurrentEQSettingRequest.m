//
//  BRHalCurrentEQSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHalCurrentEQSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRHalCurrentEQSettingRequest

#pragma BRSettingRequest

+ (BRHalCurrentEQSettingRequest *)requestWithScenario:(uint16_t)scenario eQs:(NSData *)eQs
{
	BRHalCurrentEQSettingRequest *instance = [[BRHalCurrentEQSettingRequest alloc] init];
	instance.scenario = scenario;
	instance.eQs = eQs;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_CURRENT_EQ_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"scenario", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"eQs", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHalCurrentEQSettingRequest %p> scenario=0x%04X, eQs=%@",
            self, self.scenario, self.eQs];
}

@end
