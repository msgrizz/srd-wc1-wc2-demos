//
//  BRSetTimeweightedAveragePeriodCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_TIMEWEIGHTED_AVERAGE_PERIOD 0x0F10

extern const uint8_t SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod2hours;
extern const uint8_t SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod4hours;
extern const uint8_t SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod6hours;
extern const uint8_t SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod8hours;


@interface BRSetTimeweightedAveragePeriodCommand : BRCommand

+ (BRSetTimeweightedAveragePeriodCommand *)commandWithTwa:(uint8_t)twa;

@property(nonatomic,assign) uint8_t twa;


@end
