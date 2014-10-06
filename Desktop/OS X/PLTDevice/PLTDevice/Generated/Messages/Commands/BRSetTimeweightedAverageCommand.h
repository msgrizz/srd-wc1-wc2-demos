//
//  BRSetTimeweightedAverageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_TIMEWEIGHTED_AVERAGE 0x0F0E

extern const uint8_t SetTimeweightedAverageCommand_Twa_TwaOff;
extern const uint8_t SetTimeweightedAverageCommand_Twa_Twa85dB;
extern const uint8_t SetTimeweightedAverageCommand_Twa_Twa80dB;


@interface BRSetTimeweightedAverageCommand : BRCommand

+ (BRSetTimeweightedAverageCommand *)commandWithTwa:(uint8_t)twa;

@property(nonatomic,assign) uint8_t twa;


@end
