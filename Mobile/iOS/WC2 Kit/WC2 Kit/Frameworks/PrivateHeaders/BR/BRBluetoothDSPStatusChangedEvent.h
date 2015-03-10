//
//  BRBluetoothDSPStatusChangedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_BLUETOOTH_DSP_STATUS_CHANGED_EVENT 0x0F30



@interface BRBluetoothDSPStatusChangedEvent : BREvent

@property(nonatomic,readonly) int16_t messageid;
@property(nonatomic,readonly) int16_t parametera;
@property(nonatomic,readonly) int16_t parameterb;
@property(nonatomic,readonly) int16_t parameterc;
@property(nonatomic,readonly) int16_t parameterd;


@end
