//
//  BRSetOneShortCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetOneShortCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetOneShortCommand

#pragma mark - Public

+ (BRSetOneShortCommand *)commandWithValue:(int16_t)value
{
	BRSetOneShortCommand *instance = [[BRSetOneShortCommand alloc] init];
	instance.value = value;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_ONE_SHORT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetOneShortCommand %p> value=0x%04X",
            self, self.value];
}

@end
