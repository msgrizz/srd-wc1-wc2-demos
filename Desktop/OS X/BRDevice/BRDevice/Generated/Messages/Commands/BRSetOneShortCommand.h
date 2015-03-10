//
//  BRSetOneShortCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ONE_SHORT 0x0052



@interface BRSetOneShortCommand : BRCommand

+ (BRSetOneShortCommand *)commandWithValue:(int16_t)value;

@property(nonatomic,assign) int16_t value;


@end
