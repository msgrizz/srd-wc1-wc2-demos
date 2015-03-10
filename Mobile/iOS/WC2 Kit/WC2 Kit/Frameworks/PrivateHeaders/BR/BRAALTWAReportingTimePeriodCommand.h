//
//  BRAALTWAReportingTimePeriodCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_AAL_TWA_REPORTING_TIME_PERIOD 0x0F09



@interface BRAALTWAReportingTimePeriodCommand : BRCommand

+ (BRAALTWAReportingTimePeriodCommand *)commandWithTimePeriod:(uint32_t)timePeriod;

@property(nonatomic,assign) uint32_t timePeriod;


@end
