//
//  BRBluetoothDSPLoadCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_BLUETOOTH_DSP_LOAD 0x0F34



@interface BRBluetoothDSPLoadCommand : BRCommand

+ (BRBluetoothDSPLoadCommand *)commandWithLoad:(BOOL)load;

@property(nonatomic,assign) BOOL load;


@end
