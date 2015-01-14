//
//  BRSetOneIntCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ONE_INT 0x0053



@interface BRSetOneIntCommand : BRCommand

+ (BRSetOneIntCommand *)commandWithValue:(int32_t)value;

@property(nonatomic,assign) int32_t value;


@end
