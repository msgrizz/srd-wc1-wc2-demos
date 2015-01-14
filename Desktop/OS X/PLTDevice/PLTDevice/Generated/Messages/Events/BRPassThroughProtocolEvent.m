//
//  BRPassThroughProtocolEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPassThroughProtocolEvent.h"
#import "BRMessage_Private.h"


@interface BRPassThroughProtocolEvent ()

@property(nonatomic,assign,readwrite) uint16_t protocolID;
@property(nonatomic,strong,readwrite) NSData * messageData;


@end


@implementation BRPassThroughProtocolEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PASS_THROUGH_PROTOCOL_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"protocolID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"messageData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPassThroughProtocolEvent %p> protocolID=0x%04X, messageData=%@",
            self, self.protocolID, self.messageData];
}

@end
