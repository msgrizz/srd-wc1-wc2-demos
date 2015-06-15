//
//  BRRawDataEventEnableDisableCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRRawDataEventEnableDisableCommand.h"
#import "BRMessage_Private.h"


@implementation BRRawDataEventEnableDisableCommand

#pragma mark - Public

+ (BRRawDataEventEnableDisableCommand *)command
{
	BRRawDataEventEnableDisableCommand *instance = [[BRRawDataEventEnableDisableCommand alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RAW_DATA_EVENT_ENABLEDISABLE;
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
    return [NSString stringWithFormat:@"<BRRawDataEventEnableDisableCommand %p>",
            self];
}

@end