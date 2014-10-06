//
//  BRSetPowerLevelCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_POWER_LEVEL 0x0F2A

extern const uint8_t SetPowerLevelCommand_PowerLevel_powerLevelFixedLow;
extern const uint8_t SetPowerLevelCommand_PowerLevel_powerLevelAdaptiveMedium;
extern const uint8_t SetPowerLevelCommand_PowerLevel_powerLevelAdaptiveHigh;


@interface BRSetPowerLevelCommand : BRCommand

+ (BRSetPowerLevelCommand *)commandWithPowerLevel:(uint8_t)powerLevel;

@property(nonatomic,assign) uint8_t powerLevel;


@end
