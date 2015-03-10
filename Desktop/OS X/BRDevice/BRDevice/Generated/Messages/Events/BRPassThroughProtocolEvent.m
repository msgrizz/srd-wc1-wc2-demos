//
//  BRPassThroughProtocolEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/30/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRPassThroughProtocolEvent.h"
#import "BRMessage_Private.h"


@interface BRPassThroughProtocolEvent ()

@property(nonatomic,assign,readwrite) uint16_t protocolID;
@property(nonatomic,strong,readwrite) NSData * _data;


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
			@{@"name": @"_data", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPassThroughProtocolEvent %p> protocolID=0x%04X, _data=%@",
            self, self.protocolID, self._data];
}

@end
