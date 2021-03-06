//
//  BRSetOneShortArrayCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ONE_SHORT_ARRAY 0x0056



@interface BRSetOneShortArrayCommand : BRCommand

+ (BRSetOneShortArrayCommand *)commandWithValue:(NSData *)value;

@property(nonatomic,strong) NSData * value;


@end
