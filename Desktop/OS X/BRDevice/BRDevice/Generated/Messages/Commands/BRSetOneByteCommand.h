//
//  BRSetOneByteCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_ONE_BYTE 0x0051



@interface BRSetOneByteCommand : BRCommand

+ (BRSetOneByteCommand *)commandWithValue:(uint8_t)value;

@property(nonatomic,assign) uint8_t value;


@end
