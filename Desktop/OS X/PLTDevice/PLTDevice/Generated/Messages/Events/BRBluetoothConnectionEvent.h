//
//  BRBluetoothConnectionEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_BLUETOOTH_CONNECTION_EVENT 0x0A42



@interface BRBluetoothConnectionEvent : BREvent

@property(nonatomic,readonly) uint16_t connectionOffset;
@property(nonatomic,readonly) uint16_t nap;
@property(nonatomic,readonly) uint8_t uap;
@property(nonatomic,readonly) uint32_t lap;
@property(nonatomic,readonly) uint8_t priority;
@property(nonatomic,readonly) NSString * productname;


@end
