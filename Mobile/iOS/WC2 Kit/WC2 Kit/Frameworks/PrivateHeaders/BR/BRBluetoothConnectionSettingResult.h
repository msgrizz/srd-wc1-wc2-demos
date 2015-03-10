//
//  BRBluetoothConnectionSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_BLUETOOTH_CONNECTION_SETTING_RESULT 0x0A42



@interface BRBluetoothConnectionSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t connectionOffset;
@property(nonatomic,readonly) uint16_t nap;
@property(nonatomic,readonly) uint8_t uap;
@property(nonatomic,readonly) uint32_t lap;
@property(nonatomic,readonly) uint8_t priority;
@property(nonatomic,readonly) NSString * productname;


@end
