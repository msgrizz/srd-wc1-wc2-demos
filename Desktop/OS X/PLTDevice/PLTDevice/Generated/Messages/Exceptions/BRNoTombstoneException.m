//
//  BRNoTombstoneException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRNoTombstoneException.h"
#import "BRMessage_Private.h"


@interface BRNoTombstoneException ()



@end


@implementation BRNoTombstoneException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_NO_TOMBSTONE_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[

			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRNoTombstoneException %p>",
            self];
}

@end
