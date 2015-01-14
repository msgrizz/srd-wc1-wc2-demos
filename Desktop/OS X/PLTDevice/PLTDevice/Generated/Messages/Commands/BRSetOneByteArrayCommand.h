//
//  BRSetOneByteArrayCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ONE_BYTE_ARRAY 0x0057



@interface BRSetOneByteArrayCommand : BRCommand

+ (BRSetOneByteArrayCommand *)commandWithValue:(NSData *)value;

@property(nonatomic,strong) NSData * value;


@end
