//
//  BRInvalidMessageTypeException.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRException.h"


#define BR_INVALID_MESSAGE_TYPE_EXCEPTION 0x0018



@interface BRInvalidMessageTypeException : BRException

@property(nonatomic,readonly) uint16_t invalidType;


@end
