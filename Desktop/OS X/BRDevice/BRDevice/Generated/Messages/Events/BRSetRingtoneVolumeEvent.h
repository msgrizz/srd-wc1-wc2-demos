//
//  BRSetRingtoneVolumeEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_RINGTONE_VOLUME_EVENT 0x0F06



@interface BRSetRingtoneVolumeEvent : BREvent

@property(nonatomic,readonly) uint8_t interfaceType;
@property(nonatomic,readonly) uint8_t volume;


@end
