//
//  BRStartGeneratingEventsCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRStartGeneratingEventsCommand.h"
#import "BRMessage_Private.h"


@implementation BRStartGeneratingEventsCommand

#pragma mark - Public

+ (BRStartGeneratingEventsCommand *)commandWithCount:(int32_t)count delay:(int32_t)delay dataLength:(int32_t)dataLength
{
	BRStartGeneratingEventsCommand *instance = [[BRStartGeneratingEventsCommand alloc] init];
	instance.count = count;
	instance.delay = delay;
	instance.dataLength = dataLength;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_START_GENERATING_EVENTS;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"count", @"type": @(BRPayloadItemTypeInt)},
			@{@"name": @"delay", @"type": @(BRPayloadItemTypeInt)},
			@{@"name": @"dataLength", @"type": @(BRPayloadItemTypeInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRStartGeneratingEventsCommand %p> count=0x%08X, delay=0x%08X, dataLength=0x%08X",
            self, self.count, self.delay, self.dataLength];
}

@end
