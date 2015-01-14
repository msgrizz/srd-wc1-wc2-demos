//
//  BRTwoStringsSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTwoStringsSettingResult.h"
#import "BRMessage_Private.h"


@interface BRTwoStringsSettingResult ()

@property(nonatomic,strong,readwrite) NSString * firstValue;
@property(nonatomic,strong,readwrite) NSString * secondValue;


@end


@implementation BRTwoStringsSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TWO_STRINGS_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRTwoStringsSettingResult %p> firstValue=%@, secondValue=%@",
            self, self.firstValue, self.secondValue];
}

@end
