//
//  BRThrowCommandExceptionCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRThrowCommandExceptionCommand.h"
#import "BRMessage_Private.h"


@implementation BRThrowCommandExceptionCommand

#pragma mark - Public

+ (BRThrowCommandExceptionCommand *)command
{
	BRThrowCommandExceptionCommand *instance = [[BRThrowCommandExceptionCommand alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_THROW_COMMAND_EXCEPTION;
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
    return [NSString stringWithFormat:@"<BRThrowCommandExceptionCommand %p>",
            self];
}

@end
