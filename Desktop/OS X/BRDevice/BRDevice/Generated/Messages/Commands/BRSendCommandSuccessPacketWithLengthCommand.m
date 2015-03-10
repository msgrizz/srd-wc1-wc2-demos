//
//  BRSendCommandSuccessPacketWithLengthCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSendCommandSuccessPacketWithLengthCommand.h"
#import "BRMessage_Private.h"


@implementation BRSendCommandSuccessPacketWithLengthCommand

#pragma mark - Public

+ (BRSendCommandSuccessPacketWithLengthCommand *)commandWithPacketLength:(int16_t)packetLength
{
	BRSendCommandSuccessPacketWithLengthCommand *instance = [[BRSendCommandSuccessPacketWithLengthCommand alloc] init];
	instance.packetLength = packetLength;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SEND_COMMAND_SUCCESS_PACKET_WITH_LENGTH;
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
    return [NSString stringWithFormat:@"<BRSendCommandSuccessPacketWithLengthCommand %p> packetLength=0x%04X",
            self, self.packetLength];
}

@end
