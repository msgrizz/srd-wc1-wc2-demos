//
//  BRSetOneLongCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetOneLongCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetOneLongCommand

#pragma mark - Public

+ (BRSetOneLongCommand *)commandWithValue:(int32_t)value
{
	BRSetOneLongCommand *instance = [[BRSetOneLongCommand alloc] init];
	instance.value = value;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_LONG;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeLong)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneLongCommand %p> value=0x%08X",
            self, self.value];
}

@end
