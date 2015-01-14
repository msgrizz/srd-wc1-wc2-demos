//
//  BRHalConfigureVolumeEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_HAL_CONFIGURE_VOLUME_EVENT 0x1102



@interface BRHalConfigureVolumeEvent : BREvent

@property(nonatomic,readonly) uint16_t scenario;
@property(nonatomic,readonly) NSData * volumes;


@end
