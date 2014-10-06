//
//  BRInvalidPacketTypeException.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRException.h"


#define BR_INVALID_PACKET_TYPE_EXCEPTION 0x0016



@interface BRInvalidPacketTypeException : BRException

@property(nonatomic,readonly) uint8_t invalidType;


@end
