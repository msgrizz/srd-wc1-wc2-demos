//
//  BRAALTWAReportEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_AAL_TWA_REPORT_EVENT 0x0F0B



@interface BRAALTWAReportEvent : BREvent

@property(nonatomic,readonly) uint8_t preLimiterLongTermSplEstimate;
@property(nonatomic,readonly) uint8_t postLimiterLongTermSplEstimate;


@end
