//
//  BRSetTwoBooleansCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetTwoBooleansCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetTwoBooleansCommand

#pragma mark - Public

+ (BRSetTwoBooleansCommand *)commandWithFirstValue:(BOOL)firstValue secondValue:(BOOL)secondValue
{
	BRSetTwoBooleansCommand *instance = [[BRSetTwoBooleansCommand alloc] init];
	instance.firstValue = firstValue;
	instance.secondValue = secondValue;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_TWO_BOOLEANS;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"firstValue", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"secondValue", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetTwoBooleansCommand %p> firstValue=%@, secondValue=%@",
            self, (self.firstValue ? @"YES" : @"NO"), (self.secondValue ? @"YES" : @"NO")];
}

@end
