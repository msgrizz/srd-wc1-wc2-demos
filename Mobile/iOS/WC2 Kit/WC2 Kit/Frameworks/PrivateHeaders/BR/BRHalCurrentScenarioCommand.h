//
//  BRHalCurrentScenarioCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_HAL_CURRENT_SCENARIO 0x1100

#define BRDefinedValue_HalCurrentScenarioCommand_Scenario_Current 0
#define BRDefinedValue_HalCurrentScenarioCommand_Scenario_MixedGaming 1
#define BRDefinedValue_HalCurrentScenarioCommand_Scenario_MixedGamingNoChat 2
#define BRDefinedValue_HalCurrentScenarioCommand_Scenario_MixedGamingChatIn 3
#define BRDefinedValue_HalCurrentScenarioCommand_Scenario_Conference 4
#define BRDefinedValue_HalCurrentScenarioCommand_Scenario_Phone 5
#define BRDefinedValue_HalCurrentScenarioCommand_Scenario_Media 6
#define BRDefinedValue_HalCurrentScenarioCommand_Scenario_Gaming 7


@interface BRHalCurrentScenarioCommand : BRCommand

+ (BRHalCurrentScenarioCommand *)commandWithScenario:(uint16_t)scenario;

@property(nonatomic,assign) uint16_t scenario;


@end
