//
//  BRCallEndCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCallEndCommand.h"
#import "BRMessage_Private.h"


@implementation BRCallEndCommand

#pragma mark - Public

+ (BRCallEndCommand *)command
{
	BRCallEndCommand *instance = [[BRCallEndCommand alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CALL_END;
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
    return [NSString stringWithFormat:@"<BRCallEndCommand %p>",
            self];
}

@end
