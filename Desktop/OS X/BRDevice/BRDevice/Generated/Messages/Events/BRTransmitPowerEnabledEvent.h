//
//  BRTransmitPowerEnabledEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_TRANSMIT_POWER_ENABLED_EVENT 0x0810



@interface BRTransmitPowerEnabledEvent : BREvent

@property(nonatomic,readonly) uint8_t connectionId;
@property(nonatomic,readonly) BOOL enable;


@end
