//
//  BRSetBluetoothEnabledCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_BLUETOOTH_ENABLED 0x0F24



@interface BRSetBluetoothEnabledCommand : BRCommand

+ (BRSetBluetoothEnabledCommand *)commandWithBluetoothEnabled:(BOOL)bluetoothEnabled;

@property(nonatomic,assign) BOOL bluetoothEnabled;


@end
