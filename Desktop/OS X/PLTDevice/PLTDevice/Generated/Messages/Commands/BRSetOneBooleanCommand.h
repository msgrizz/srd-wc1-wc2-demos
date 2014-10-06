//
//  BRSetOneBooleanCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ONE_BOOLEAN 0x0050



@interface BRSetOneBooleanCommand : BRCommand

+ (BRSetOneBooleanCommand *)commandWithValue:(BOOL)value;

@property(nonatomic,assign) BOOL value;


@end
