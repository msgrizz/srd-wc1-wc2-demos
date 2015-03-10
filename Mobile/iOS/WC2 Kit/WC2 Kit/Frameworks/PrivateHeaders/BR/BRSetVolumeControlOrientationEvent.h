//
//  BRSetVolumeControlOrientationEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_VOLUME_CONTROL_ORIENTATION_EVENT 0x0F2E



@interface BRSetVolumeControlOrientationEvent : BREvent

@property(nonatomic,readonly) uint8_t orientation;


@end
