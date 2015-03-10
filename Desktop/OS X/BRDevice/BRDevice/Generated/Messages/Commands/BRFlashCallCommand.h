//
//  BRFlashCallCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_FLASH_CALL 0x0E10



@interface BRFlashCallCommand : BRCommand

+ (BRFlashCallCommand *)commandWithValue:(uint16_t)value;

@property(nonatomic,assign) uint16_t value;


@end
