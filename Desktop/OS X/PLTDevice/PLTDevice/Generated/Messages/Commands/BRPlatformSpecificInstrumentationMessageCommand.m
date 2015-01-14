//
//  BRPlatformSpecificInstrumentationMessageCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPlatformSpecificInstrumentationMessageCommand.h"
#import "BRMessage_Private.h"


@implementation BRPlatformSpecificInstrumentationMessageCommand

#pragma mark - Public

+ (BRPlatformSpecificInstrumentationMessageCommand *)commandWithData:(NSData *)data
{
	BRPlatformSpecificInstrumentationMessageCommand *instance = [[BRPlatformSpecificInstrumentationMessageCommand alloc] init];
	instance.data = data;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PLATFORM_SPECIFIC_INSTRUMENTATION_MESSAGE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"data", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPlatformSpecificInstrumentationMessageCommand %p> data=%@",
            self, self.data];
}

@end
