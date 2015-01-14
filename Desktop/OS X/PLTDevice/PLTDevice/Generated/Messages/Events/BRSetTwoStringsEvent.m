//
//  BRSetTwoStringsEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetTwoStringsEvent.h"
#import "BRMessage_Private.h"


@interface BRSetTwoStringsEvent ()

@property(nonatomic,strong,readwrite) NSString * firstValue;
@property(nonatomic,strong,readwrite) NSString * secondValue;


@end


@implementation BRSetTwoStringsEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_TWO_STRINGS_EVENT;
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
    return [NSString stringWithFormat:@"<BRSetTwoStringsEvent %p> firstValue=%@, secondValue=%@",
            self, self.firstValue, self.secondValue];
}

@end
