//
//  BRConfigureMuteReminderTimingCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_MUTE_REMINDER_TIMING 0x0A20



@interface BRConfigureMuteReminderTimingCommand : BRCommand

+ (BRConfigureMuteReminderTimingCommand *)commandWithSeconds:(uint16_t)seconds;

@property(nonatomic,assign) uint16_t seconds;


@end
