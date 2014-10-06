//
//  BRHalCurrentScenarioCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHalCurrentScenarioCommand.h"
#import "BRMessage_Private.h"


const uint16_t HalCurrentScenarioCommand_Scenario_Current = 0;
const uint16_t HalCurrentScenarioCommand_Scenario_MixedGaming = 1;
const uint16_t HalCurrentScenarioCommand_Scenario_MixedGamingNoChat = 2;
const uint16_t HalCurrentScenarioCommand_Scenario_MixedGamingChatIn = 3;
const uint16_t HalCurrentScenarioCommand_Scenario_Conference = 4;
const uint16_t HalCurrentScenarioCommand_Scenario_Phone = 5;
const uint16_t HalCurrentScenarioCommand_Scenario_Media = 6;
const uint16_t HalCurrentScenarioCommand_Scenario_Gaming = 7;


@implementation BRHalCurrentScenarioCommand

#pragma mark - Public

+ (BRHalCurrentScenarioCommand *)commandWithScenario:(uint16_t)scenario
{
	BRHalCurrentScenarioCommand *instance = [[BRHalCurrentScenarioCommand alloc] init];
	instance.scenario = scenario;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_CURRENT_SCENARIO;
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
    return [NSString stringWithFormat:@"<BRHalCurrentScenarioCommand %p> scenario=0x%04X",
            self, self.scenario];
}

@end
