//
//  BRGenesGUIDAlreadySetException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRGenesGUIDAlreadySetException.h"
#import "BRMessage_Private.h"


@interface BRGenesGUIDAlreadySetException ()



@end


@implementation BRGenesGUIDAlreadySetException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GENES_GUID_ALREADY_SET_EXCEPTION;
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
    return [NSString stringWithFormat:@"<BRGenesGUIDAlreadySetException %p>",
            self];
}

@end
