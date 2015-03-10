//
//  BRConversationDynamicsReportEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CONVERSATION_DYNAMICS_REPORT_EVENT 0x0F11



@interface BRConversationDynamicsReportEvent : BREvent

@property(nonatomic,readonly) uint16_t timePeriod;
@property(nonatomic,readonly) uint16_t farEndDuration;
@property(nonatomic,readonly) uint16_t nearEndDuration;
@property(nonatomic,readonly) uint16_t crosstalkDuration;
@property(nonatomic,readonly) uint16_t noTalkDuration;


@end
