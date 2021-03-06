//
//  BRBluetoothConnectionSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_BLUETOOTH_CONNECTION_SETTING_REQUEST 0x0A42



@interface BRBluetoothConnectionSettingRequest : BRSettingRequest

+ (BRBluetoothConnectionSettingRequest *)requestWithConnectionOffset:(uint16_t)connectionOffset;

@property(nonatomic,assign) uint16_t connectionOffset;


@end
