//
//  BRSetG616Command.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_G616 0x0F0C



@interface BRSetG616Command : BRCommand

+ (BRSetG616Command *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
