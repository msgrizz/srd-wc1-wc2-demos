//
//  BRUserDefinedStorageChangedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRUserDefinedStorageChangedEvent.h"
#import "BRMessage_Private.h"


@interface BRUserDefinedStorageChangedEvent ()



@end


@implementation BRUserDefinedStorageChangedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_USER_DEFINED_STORAGE_CHANGED_EVENT;
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
    return [NSString stringWithFormat:@"<BRUserDefinedStorageChangedEvent %p>",
            self];
}

@end
