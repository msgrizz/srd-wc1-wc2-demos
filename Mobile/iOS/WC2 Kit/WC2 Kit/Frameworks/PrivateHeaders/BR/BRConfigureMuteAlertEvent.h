//
//  BRConfigureMuteAlertEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CONFIGURE_MUTE_ALERT_EVENT 0x040A



@interface BRConfigureMuteAlertEvent : BREvent

@property(nonatomic,readonly) uint8_t mode;
@property(nonatomic,readonly) uint8_t parameter;


@end