//
//  BRInvalidPacketLengthException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRInvalidPacketLengthException.h"
#import "BRMessage_Private.h"


@interface BRInvalidPacketLengthException ()

@property(nonatomic,assign,readwrite) uint16_t invalidLength;


@end


@implementation BRInvalidPacketLengthException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_INVALID_PACKET_LENGTH_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"invalidLength", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRInvalidPacketLengthException %p> invalidLength=0x%04X",
            self, self.invalidLength];
}

@end
