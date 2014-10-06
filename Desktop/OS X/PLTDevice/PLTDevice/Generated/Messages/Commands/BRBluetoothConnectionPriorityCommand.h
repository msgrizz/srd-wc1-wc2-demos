//
//  BRBluetoothConnectionPriorityCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_BLUETOOTH_CONNECTION_PRIORITY 0x0A44



@interface BRBluetoothConnectionPriorityCommand : BRCommand

+ (BRBluetoothConnectionPriorityCommand *)commandWithConnectionOffset:(uint16_t)connectionOffset allowSmartDisconnect:(BOOL)allowSmartDisconnect;

@property(nonatomic,assign) uint16_t connectionOffset;
@property(nonatomic,assign) BOOL allowSmartDisconnect;


@end
