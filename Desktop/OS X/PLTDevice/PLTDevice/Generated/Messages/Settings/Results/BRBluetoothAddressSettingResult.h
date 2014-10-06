//
//  BRBluetoothAddressSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_BLUETOOTH_ADDRESS_SETTING_RESULT 0x0A40



@interface BRBluetoothAddressSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t nap;
@property(nonatomic,readonly) uint8_t uap;
@property(nonatomic,readonly) uint32_t lap;


@end
