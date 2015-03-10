//
//  BRSetOneBooleanCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ONE_BOOLEAN 0x0050



@interface BRSetOneBooleanCommand : BRCommand

+ (BRSetOneBooleanCommand *)commandWithValue:(BOOL)value;

@property(nonatomic,assign) BOOL value;


@end
