//
//  BRConnectedDeviceEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CONNECTED_DEVICE_EVENT 0x0C00



@interface BRConnectedDeviceEvent : BREvent

@property(nonatomic,readonly) uint8_t address;


@end
