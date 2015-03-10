//
//  BROneStringSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BROneStringSettingResult.h"
#import "BRMessage_Private.h"


@interface BROneStringSettingResult ()

@property(nonatomic,strong,readwrite) NSString * value;


@end


@implementation BROneStringSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_ONE_STRING_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROneStringSettingResult %p> value=%@",
            self, self.value];
}

@end
