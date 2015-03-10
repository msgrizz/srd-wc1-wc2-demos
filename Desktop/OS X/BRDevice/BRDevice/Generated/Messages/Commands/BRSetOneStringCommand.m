//
//  BRSetOneStringCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetOneStringCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetOneStringCommand

#pragma mark - Public

+ (BRSetOneStringCommand *)commandWithValue:(NSString *)value
{
	BRSetOneStringCommand *instance = [[BRSetOneStringCommand alloc] init];
	instance.value = value;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_STRING;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneStringCommand %p> value=%@",
            self, self.value];
}

@end
