//
//  BRHalCurrentScenarioCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_HAL_CURRENT_SCENARIO 0x1100

extern const uint16_t HalCurrentScenarioCommand_Scenario_Current;
extern const uint16_t HalCurrentScenarioCommand_Scenario_MixedGaming;
extern const uint16_t HalCurrentScenarioCommand_Scenario_MixedGamingNoChat;
extern const uint16_t HalCurrentScenarioCommand_Scenario_MixedGamingChatIn;
extern const uint16_t HalCurrentScenarioCommand_Scenario_Conference;
extern const uint16_t HalCurrentScenarioCommand_Scenario_Phone;
extern const uint16_t HalCurrentScenarioCommand_Scenario_Media;
extern const uint16_t HalCurrentScenarioCommand_Scenario_Gaming;


@interface BRHalCurrentScenarioCommand : BRCommand

+ (BRHalCurrentScenarioCommand *)commandWithScenario:(uint16_t)scenario;

@property(nonatomic,assign) uint16_t scenario;


@end
