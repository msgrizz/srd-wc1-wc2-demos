//
//  BRConfigureMuteReminderTimingCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_MUTE_REMINDER_TIMING 0x0A20



@interface BRConfigureMuteReminderTimingCommand : BRCommand

+ (BRConfigureMuteReminderTimingCommand *)commandWithSeconds:(uint16_t)seconds;

@property(nonatomic,assign) uint16_t seconds;


@end
