//
//  BRMemoryAllocationFailedException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRMemoryAllocationFailedException.h"
#import "BRMessage_Private.h"


@interface BRMemoryAllocationFailedException ()



@end


@implementation BRMemoryAllocationFailedException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MEMORY_ALLOCATION_FAILED_EXCEPTION;
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
    return [NSString stringWithFormat:@"<BRMemoryAllocationFailedException %p>",
            self];
}

@end
