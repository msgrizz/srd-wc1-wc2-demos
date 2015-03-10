//
//  BRClosePhysicalConnectionCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CLOSE_PHYSICAL_CONNECTION 0x0103



@interface BRClosePhysicalConnectionCommand : BRCommand

+ (BRClosePhysicalConnectionCommand *)commandWithMilliseconds:(int16_t)milliseconds;

@property(nonatomic,assign) int16_t milliseconds;


@end
