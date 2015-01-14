//
//  BRDisconnectedDeviceEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_DISCONNECTED_DEVICE_EVENT 0x0C02



@interface BRDisconnectedDeviceEvent : BREvent

@property(nonatomic,readonly) uint8_t address;


@end
