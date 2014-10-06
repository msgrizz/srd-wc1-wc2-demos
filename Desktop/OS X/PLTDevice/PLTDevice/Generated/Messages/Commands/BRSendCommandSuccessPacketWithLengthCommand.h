//
//  BRSendCommandSuccessPacketWithLengthCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SEND_COMMAND_SUCCESS_PACKET_WITH_LENGTH 0x0101



@interface BRSendCommandSuccessPacketWithLengthCommand : BRCommand

+ (BRSendCommandSuccessPacketWithLengthCommand *)commandWithPacketLength:(int16_t)packetLength;

@property(nonatomic,assign) int16_t packetLength;


@end
