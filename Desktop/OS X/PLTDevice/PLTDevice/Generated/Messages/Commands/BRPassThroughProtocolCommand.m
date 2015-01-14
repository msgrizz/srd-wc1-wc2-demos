//
//  BRPassThroughProtocolCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPassThroughProtocolCommand.h"
#import "BRMessage_Private.h"


@implementation BRPassThroughProtocolCommand

#pragma mark - Public

+ (BRPassThroughProtocolCommand *)commandWithProtocolid:(uint16_t)protocolid messageData:(NSData *)messageData
{
	BRPassThroughProtocolCommand *instance = [[BRPassThroughProtocolCommand alloc] init];
	instance.protocolid = protocolid;
	instance.messageData = messageData;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PASS_THROUGH_PROTOCOL;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"protocolid", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"messageData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPassThroughProtocolCommand %p> protocolid=0x%04X, messageData=%@",
            self, self.protocolid, self.messageData];
}

@end
