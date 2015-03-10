//
//  BRHalCurrentScenarioSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRHalCurrentScenarioSettingResult.h"
#import "BRMessage_Private.h"


@interface BRHalCurrentScenarioSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t scenario;


@end


@implementation BRHalCurrentScenarioSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_CURRENT_SCENARIO_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"scenario", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHalCurrentScenarioSettingResult %p> scenario=0x%04X",
            self, self.scenario];
}

@end
