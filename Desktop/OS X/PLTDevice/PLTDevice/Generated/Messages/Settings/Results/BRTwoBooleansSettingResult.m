//
//  BRTwoBooleansSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTwoBooleansSettingResult.h"
#import "BRMessage_Private.h"




@interface BRTwoBooleansSettingResult ()

@property(nonatomic,assign,readwrite) BOOL firstValue;
@property(nonatomic,assign,readwrite) BOOL secondValue;


@end


@implementation BRTwoBooleansSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TWO_BOOLEANS_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRTwoBooleansSettingResult %p> firstValue=%@, secondValue=%@",
            self, (self.firstValue ? @"YES" : @"NO"), (self.secondValue ? @"YES" : @"NO")];
}

@end
