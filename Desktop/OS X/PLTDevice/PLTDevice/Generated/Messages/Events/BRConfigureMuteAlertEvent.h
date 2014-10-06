//
//  BRConfigureMuteAlertEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CONFIGURE_MUTE_ALERT_EVENT 0x040A



@interface BRConfigureMuteAlertEvent : BREvent

@property(nonatomic,readonly) uint8_t mode;
@property(nonatomic,readonly) uint8_t parameter;


@end
