//
//  BRConfigureA2DPCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_A2DP 0x0A0C



@interface BRConfigureA2DPCommand : BRCommand

+ (BRConfigureA2DPCommand *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
