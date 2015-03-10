//
//  BRPartNumberCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRPartNumberCommand.h"
#import "BRMessage_Private.h"


@implementation BRPartNumberCommand

#pragma mark - Public

+ (BRPartNumberCommand *)commandWithPartNumber:(uint32_t)partNumber
{
	BRPartNumberCommand *instance = [[BRPartNumberCommand alloc] init];
	instance.partNumber = partNumber;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PART_NUMBER;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"partNumber", @"type": @(BRPayloadItemTypeUnsignedInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPartNumberCommand %p> partNumber=0x%08X",
            self, self.partNumber];
}

@end
