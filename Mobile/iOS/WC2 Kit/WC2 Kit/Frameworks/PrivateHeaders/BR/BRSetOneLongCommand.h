//
//  BRSetOneLongCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ONE_LONG 0x0054



@interface BRSetOneLongCommand : BRCommand

+ (BRSetOneLongCommand *)commandWithValue:(int32_t)value;

@property(nonatomic,assign) int32_t value;


@end
