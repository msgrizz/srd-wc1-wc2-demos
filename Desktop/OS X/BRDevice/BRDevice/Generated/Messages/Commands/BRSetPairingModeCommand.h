//
//  BRSetPairingModeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_PAIRING_MODE 0x0A24



@interface BRSetPairingModeCommand : BRCommand

+ (BRSetPairingModeCommand *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
