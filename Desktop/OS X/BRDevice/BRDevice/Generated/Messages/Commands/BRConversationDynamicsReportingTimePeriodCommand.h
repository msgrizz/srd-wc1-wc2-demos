//
//  BRConversationDynamicsReportingTimePeriodCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD 0x0F0F



@interface BRConversationDynamicsReportingTimePeriodCommand : BRCommand

+ (BRConversationDynamicsReportingTimePeriodCommand *)commandWithTimePeriod:(uint32_t)timePeriod;

@property(nonatomic,assign) uint32_t timePeriod;


@end
