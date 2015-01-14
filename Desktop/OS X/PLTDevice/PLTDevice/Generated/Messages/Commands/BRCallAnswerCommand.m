//
//  BRCallAnswerCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCallAnswerCommand.h"
#import "BRMessage_Private.h"


@implementation BRCallAnswerCommand

#pragma mark - Public

+ (BRCallAnswerCommand *)command
{
	BRCallAnswerCommand *instance = [[BRCallAnswerCommand alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CALL_ANSWER;
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
    return [NSString stringWithFormat:@"<BRCallAnswerCommand %p>",
            self];
}

@end
