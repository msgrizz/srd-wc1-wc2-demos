//
//  BRConfigureMuteToneVolumeEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CONFIGURE_MUTE_TONE_VOLUME_EVENT 0x0400



@interface BRConfigureMuteToneVolumeEvent : BREvent

@property(nonatomic,readonly) uint8_t muteToneVolume;


@end
