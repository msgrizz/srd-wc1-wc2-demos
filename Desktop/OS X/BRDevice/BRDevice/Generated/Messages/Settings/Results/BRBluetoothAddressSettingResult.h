//
//  BRBluetoothAddressSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_BLUETOOTH_ADDRESS_SETTING_RESULT 0x0A40



@interface BRBluetoothAddressSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t nap;
@property(nonatomic,readonly) uint8_t uap;
@property(nonatomic,readonly) uint32_t lap;


@end
