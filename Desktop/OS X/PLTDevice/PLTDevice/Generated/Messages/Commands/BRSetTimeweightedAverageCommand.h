//
//  BRSetTimeweightedAverageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_TIMEWEIGHTED_AVERAGE 0x0F0E

#define BRDefinedValue_SetTimeweightedAverageCommand_Twa_TwaOff 0
#define BRDefinedValue_SetTimeweightedAverageCommand_Twa_Twa85dB 1
#define BRDefinedValue_SetTimeweightedAverageCommand_Twa_Twa80dB 2


@interface BRSetTimeweightedAverageCommand : BRCommand

+ (BRSetTimeweightedAverageCommand *)commandWithTwa:(uint8_t)twa;

@property(nonatomic,assign) uint8_t twa;


@end
