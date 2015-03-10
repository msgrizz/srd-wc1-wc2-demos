//
//  BRSetOneShortArrayCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetOneShortArrayCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetOneShortArrayCommand

#pragma mark - Public

+ (BRSetOneShortArrayCommand *)commandWithValue:(NSData *)value
{
	BRSetOneShortArrayCommand *instance = [[BRSetOneShortArrayCommand alloc] init];
	instance.value = value;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_SHORT_ARRAY;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneShortArrayCommand %p> value=%@",
            self, self.value];
}

@end
