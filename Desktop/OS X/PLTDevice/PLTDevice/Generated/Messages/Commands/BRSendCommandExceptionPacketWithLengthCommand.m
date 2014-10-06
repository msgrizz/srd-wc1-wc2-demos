//
//  BRSendCommandExceptionPacketWithLengthCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSendCommandExceptionPacketWithLengthCommand.h"
#import "BRMessage_Private.h"




@implementation BRSendCommandExceptionPacketWithLengthCommand

#pragma mark - Public

+ (BRSendCommandExceptionPacketWithLengthCommand *)commandWithPacketLength:(int16_t)packetLength
{
	BRSendCommandExceptionPacketWithLengthCommand *instance = [[BRSendCommandExceptionPacketWithLengthCommand alloc] init];
	instance.packetLength = packetLength;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SEND_COMMAND_EXCEPTION_PACKET_WITH_LENGTH;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"packetLength", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSendCommandExceptionPacketWithLengthCommand %p> packetLength=0x%04X",
            self, self.packetLength];
}

@end
