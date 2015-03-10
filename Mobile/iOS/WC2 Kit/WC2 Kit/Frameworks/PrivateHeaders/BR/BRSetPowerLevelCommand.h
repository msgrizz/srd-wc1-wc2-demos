//
//  BRSetPowerLevelCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_POWER_LEVEL 0x0F2A

#define BRDefinedValue_SetPowerLevelCommand_PowerLevel_powerLevelFixedLow 0
#define BRDefinedValue_SetPowerLevelCommand_PowerLevel_powerLevelAdaptiveMedium 1
#define BRDefinedValue_SetPowerLevelCommand_PowerLevel_powerLevelAdaptiveHigh 2


@interface BRSetPowerLevelCommand : BRCommand

+ (BRSetPowerLevelCommand *)commandWithPowerLevel:(uint8_t)powerLevel;

@property(nonatomic,assign) uint8_t powerLevel;


@end
