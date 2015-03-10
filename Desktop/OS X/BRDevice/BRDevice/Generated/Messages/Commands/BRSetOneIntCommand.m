//
//  BRSetOneIntCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetOneIntCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetOneIntCommand

#pragma mark - Public

+ (BRSetOneIntCommand *)commandWithValue:(int32_t)value
{
	BRSetOneIntCommand *instance = [[BRSetOneIntCommand alloc] init];
	instance.value = value;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_INT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneIntCommand %p> value=0x%08X",
            self, self.value];
}

@end
