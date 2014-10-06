//
//  BRSetTwoStringsCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetTwoStringsCommand.h"
#import "BRMessage_Private.h"




@implementation BRSetTwoStringsCommand

#pragma mark - Public

+ (BRSetTwoStringsCommand *)commandWithFirstValue:(NSString *)firstValue secondValue:(NSString *)secondValue
{
	BRSetTwoStringsCommand *instance = [[BRSetTwoStringsCommand alloc] init];
	instance.firstValue = firstValue;
	instance.secondValue = secondValue;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_TWO_STRINGS;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"firstValue", @"type": @(BRPayloadItemTypeString)},
			@{@"name": @"secondValue", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetTwoStringsCommand %p> firstValue=%@, secondValue=%@",
            self, self.firstValue, self.secondValue];
}

@end
