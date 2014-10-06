//
//  BRYCableConnectionCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_Y_CABLE_CONNECTION 0x0E0B



@interface BRYCableConnectionCommand : BRCommand

+ (BRYCableConnectionCommand *)commandWithState:(BOOL)state;

@property(nonatomic,assign) BOOL state;


@end
