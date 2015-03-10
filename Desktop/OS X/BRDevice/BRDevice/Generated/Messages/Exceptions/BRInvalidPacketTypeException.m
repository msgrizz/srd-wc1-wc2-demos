//
//  BRInvalidPacketTypeException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRInvalidPacketTypeException.h"
#import "BRMessage_Private.h"


@interface BRInvalidPacketTypeException ()

@property(nonatomic,assign,readwrite) uint8_t invalidType;


@end


@implementation BRInvalidPacketTypeException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_INVALID_PACKET_TYPE_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"invalidType", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRInvalidPacketTypeException %p> invalidType=0x%02X",
            self, self.invalidType];
}

@end
