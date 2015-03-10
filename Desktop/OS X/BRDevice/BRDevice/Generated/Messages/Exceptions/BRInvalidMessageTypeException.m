//
//  BRInvalidMessageTypeException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRInvalidMessageTypeException.h"
#import "BRMessage_Private.h"


@interface BRInvalidMessageTypeException ()

@property(nonatomic,assign,readwrite) uint16_t invalidType;


@end


@implementation BRInvalidMessageTypeException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_INVALID_MESSAGE_TYPE_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"invalidType", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRInvalidMessageTypeException %p> invalidType=0x%04X",
            self, self.invalidType];
}

@end
