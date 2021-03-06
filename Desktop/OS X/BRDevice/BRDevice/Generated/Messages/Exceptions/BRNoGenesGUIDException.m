//
//  BRNoGenesGUIDException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRNoGenesGUIDException.h"
#import "BRMessage_Private.h"


@interface BRNoGenesGUIDException ()



@end


@implementation BRNoGenesGUIDException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_NO_GENES_GUID_EXCEPTION;
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
    return [NSString stringWithFormat:@"<BRNoGenesGUIDException %p>",
            self];
}

@end
