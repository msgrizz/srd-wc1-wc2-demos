//
//  BRFlashCallCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRFlashCallCommand.h"
#import "BRMessage_Private.h"




@implementation BRFlashCallCommand

#pragma mark - Public

+ (BRFlashCallCommand *)commandWithValue:(uint16_t)value
{
	BRFlashCallCommand *instance = [[BRFlashCallCommand alloc] init];
	instance.value = value;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FLASH_CALL;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRFlashCallCommand %p> value=0x%04X",
            self, self.value];
}

@end
