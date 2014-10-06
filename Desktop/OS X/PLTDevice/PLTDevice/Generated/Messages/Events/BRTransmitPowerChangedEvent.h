//
//  BRTransmitPowerChangedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_TRANSMIT_POWER_CHANGED_EVENT 0x0812



@interface BRTransmitPowerChangedEvent : BREvent

@property(nonatomic,readonly) uint8_t connectionId;
@property(nonatomic,readonly) int16_t power;


@end
