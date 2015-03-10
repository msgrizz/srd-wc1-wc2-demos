//
//  BRBluetoothAddPairingCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_BLUETOOTH_ADD_PAIRING 0x0A4A



@interface BRBluetoothAddPairingCommand : BRCommand

+ (BRBluetoothAddPairingCommand *)commandWithConnectionOffset:(uint16_t)connectionOffset persist:(BOOL)persist nap:(uint16_t)nap uap:(uint8_t)uap lap:(uint32_t)lap linkKeyType:(uint16_t)linkKeyType linkKey:(NSData *)linkKey;

@property(nonatomic,assign) uint16_t connectionOffset;
@property(nonatomic,assign) BOOL persist;
@property(nonatomic,assign) uint16_t nap;
@property(nonatomic,assign) uint8_t uap;
@property(nonatomic,assign) uint32_t lap;
@property(nonatomic,assign) uint16_t linkKeyType;
@property(nonatomic,strong) NSData * linkKey;


@end
