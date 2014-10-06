//
//  BRConversationDynamicsReportingTimePeriodCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD 0x0F0F



@interface BRConversationDynamicsReportingTimePeriodCommand : BRCommand

+ (BRConversationDynamicsReportingTimePeriodCommand *)commandWithTimePeriod:(uint32_t)timePeriod;

@property(nonatomic,assign) uint32_t timePeriod;


@end
