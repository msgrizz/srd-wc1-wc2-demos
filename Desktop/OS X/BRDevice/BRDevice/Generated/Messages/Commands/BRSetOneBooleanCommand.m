//
//  BRSetOneBooleanCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetOneBooleanCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetOneBooleanCommand

#pragma mark - Public

+ (BRSetOneBooleanCommand *)commandWithValue:(BOOL)value
{
	BRSetOneBooleanCommand *instance = [[BRSetOneBooleanCommand alloc] init];
	instance.value = value;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_BOOLEAN;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneBooleanCommand %p> value=%@",
            self, (self.value ? @"YES" : @"NO")];
}

@end
