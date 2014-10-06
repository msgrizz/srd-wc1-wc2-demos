//
//  BRPassThroughProtocolCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPassThroughProtocolCommand.h"
#import "BRMessage_Private.h"


const uint16_t PassThroughProtocolCommand_ProtocolID_ProtocolAPDU = 1;


@implementation BRPassThroughProtocolCommand

#pragma mark - Public

+ (BRPassThroughProtocolCommand *)commandWithProtocolID:(uint16_t)protocolID data:(NSData *)data
{
	BRPassThroughProtocolCommand *instance = [[BRPassThroughProtocolCommand alloc] init];
	instance.protocolID = protocolID;
	instance.data = data;
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
			@{@"name": @"protocolID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"data", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPassThroughProtocolCommand %p> protocolID=0x%04X, data=%@",
            self, self.protocolID, self.data];
}

@end
