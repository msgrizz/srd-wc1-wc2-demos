//
//  BRSetOneByteCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetOneByteCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetOneByteCommand

#pragma mark - Public

+ (BRSetOneByteCommand *)commandWithValue:(uint8_t)value
{
	BRSetOneByteCommand *instance = [[BRSetOneByteCommand alloc] init];
	instance.value = value;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_BYTE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneByteCommand %p> value=0x%02X",
            self, self.value];
}

@end
