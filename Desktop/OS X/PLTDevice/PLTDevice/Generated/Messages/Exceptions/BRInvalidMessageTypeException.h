//
//  BRInvalidMessageTypeException.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRException.h"


#define BR_INVALID_MESSAGE_TYPE_EXCEPTION 0x0018



@interface BRInvalidMessageTypeException : BRException

@property(nonatomic,readonly) uint16_t invalidType;


@end
