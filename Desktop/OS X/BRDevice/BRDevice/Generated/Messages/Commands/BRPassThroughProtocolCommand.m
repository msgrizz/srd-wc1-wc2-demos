//
//  BRPassThroughProtocolCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/30/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRPassThroughProtocolCommand.h"
#import "BRMessage_Private.h"


@implementation BRPassThroughProtocolCommand

#pragma mark - Public

+ (BRPassThroughProtocolCommand *)commandWithProtocolid:(uint16_t)protocolid _data:(NSData *)_data
{
	BRPassThroughProtocolCommand *instance = [[BRPassThroughProtocolCommand alloc] init];
	instance.protocolid = protocolid;
	instance._data = _data;
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
			@{@"name": @"_data", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPassThroughProtocolCommand %p> protocolid=0x%04X, _data=%@",
            self, self.protocolid, self._data];
}

@end
