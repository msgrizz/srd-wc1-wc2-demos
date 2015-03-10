//
//  BRAALTWAReportingTimePeriodEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_AAL_TWA_REPORTING_TIME_PERIOD_EVENT 0x0F09



@interface BRAALTWAReportingTimePeriodEvent : BREvent

@property(nonatomic,readonly) uint32_t timePeriod;


@end
