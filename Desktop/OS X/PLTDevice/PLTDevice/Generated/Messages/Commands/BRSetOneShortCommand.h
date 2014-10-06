//
//  BRSetOneShortCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ONE_SHORT 0x0052



@interface BRSetOneShortCommand : BRCommand

+ (BRSetOneShortCommand *)commandWithValue:(int16_t)value;

@property(nonatomic,assign) int16_t value;


@end
