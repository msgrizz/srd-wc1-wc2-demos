//
//  BRInvalidPacketLengthException.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRException.h"


#define BR_INVALID_PACKET_LENGTH_EXCEPTION 0x0014



@interface BRInvalidPacketLengthException : BRException

@property(nonatomic,readonly) uint16_t invalidLength;


@end
