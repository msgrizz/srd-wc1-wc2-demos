//
//  BRRawDataCommandCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRawDataCommandCommand.h"
#import "BRMessage_Private.h"


@implementation BRRawDataCommandCommand

#pragma mark - Public

+ (BRRawDataCommandCommand *)command
{
	BRRawDataCommandCommand *instance = [[BRRawDataCommandCommand alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RAW_DATA_COMMAND;
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
    return [NSString stringWithFormat:@"<BRRawDataCommandCommand %p>",
            self];
}

@end
