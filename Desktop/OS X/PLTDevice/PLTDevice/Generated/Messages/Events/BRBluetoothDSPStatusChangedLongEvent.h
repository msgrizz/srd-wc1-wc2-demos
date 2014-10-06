//
//  BRBluetoothDSPStatusChangedLongEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_BLUETOOTH_DSP_STATUS_CHANGED_LONG_EVENT 0x0F32



@interface BRBluetoothDSPStatusChangedLongEvent : BREvent

@property(nonatomic,readonly) int16_t keyAddr;
@property(nonatomic,readonly) NSData * keyParameter;


@end
