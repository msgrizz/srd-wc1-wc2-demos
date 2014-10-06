//
//  BRTransmitPowerEnabledEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_TRANSMIT_POWER_ENABLED_EVENT 0x0810



@interface BRTransmitPowerEnabledEvent : BREvent

@property(nonatomic,readonly) uint8_t connectionId;
@property(nonatomic,readonly) BOOL enable;


@end
