//
//  BRSetOneByteArrayCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetOneByteArrayCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetOneByteArrayCommand

#pragma mark - Public

+ (BRSetOneByteArrayCommand *)commandWithValue:(NSData *)value
{
	BRSetOneByteArrayCommand *instance = [[BRSetOneByteArrayCommand alloc] init];
	instance.value = value;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_BYTE_ARRAY;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneByteArrayCommand %p> value=%@",
            self, self.value];
}

@end
