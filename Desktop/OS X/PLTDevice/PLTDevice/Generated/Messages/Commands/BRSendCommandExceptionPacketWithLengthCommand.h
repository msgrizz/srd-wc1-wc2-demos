//
//  BRSendCommandExceptionPacketWithLengthCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SEND_COMMAND_EXCEPTION_PACKET_WITH_LENGTH 0x0102



@interface BRSendCommandExceptionPacketWithLengthCommand : BRCommand

+ (BRSendCommandExceptionPacketWithLengthCommand *)commandWithPacketLength:(int16_t)packetLength;

@property(nonatomic,assign) int16_t packetLength;


@end
