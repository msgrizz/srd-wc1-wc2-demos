//
//  BRSetTimeweightedAveragePeriodCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_TIMEWEIGHTED_AVERAGE_PERIOD 0x0F10

#define BRDefinedValue_SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod2hours 1
#define BRDefinedValue_SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod4hours 2
#define BRDefinedValue_SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod6hours 3
#define BRDefinedValue_SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod8hours 4


@interface BRSetTimeweightedAveragePeriodCommand : BRCommand

+ (BRSetTimeweightedAveragePeriodCommand *)commandWithTwa:(uint8_t)twa;

@property(nonatomic,assign) uint8_t twa;


@end
