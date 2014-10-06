//
//  BRClearTombstoneCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRClearTombstoneCommand.h"
#import "BRMessage_Private.h"




@implementation BRClearTombstoneCommand

#pragma mark - Public

+ (BRClearTombstoneCommand *)command
{
	BRClearTombstoneCommand *instance = [[BRClearTombstoneCommand alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CLEAR_TOMBSTONE;
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
    return [NSString stringWithFormat:@"<BRClearTombstoneCommand %p>",
            self];
}

@end
