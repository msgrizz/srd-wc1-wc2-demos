//
//  BRBluetoothDeletePairingCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_BLUETOOTH_DELETE_PAIRING 0x0A48



@interface BRBluetoothDeletePairingCommand : BRCommand

+ (BRBluetoothDeletePairingCommand *)commandWithConnectionOffset:(uint16_t)connectionOffset;

@property(nonatomic,assign) uint16_t connectionOffset;


@end
