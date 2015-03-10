//
//  BRInvalidPayloadDataException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRInvalidPayloadDataException.h"
#import "BRMessage_Private.h"


@interface BRInvalidPayloadDataException ()

@property(nonatomic,strong,readwrite) NSData * modes;


@end


@implementation BRInvalidPayloadDataException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_INVALID_PAYLOAD_DATA_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"modes", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRInvalidPayloadDataException %p> modes=%@",
            self, self.modes];
}

@end
