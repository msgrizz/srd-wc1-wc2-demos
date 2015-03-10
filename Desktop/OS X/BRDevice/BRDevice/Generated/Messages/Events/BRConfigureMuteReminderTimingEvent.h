//
//  BRConfigureMuteReminderTimingEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CONFIGURE_MUTE_REMINDER_TIMING_EVENT 0x0A20



@interface BRConfigureMuteReminderTimingEvent : BREvent

@property(nonatomic,readonly) uint16_t seconds;


@end
