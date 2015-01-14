//
//  BROneIntSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROneIntSettingResult.h"
#import "BRMessage_Private.h"


@interface BROneIntSettingResult ()

@property(nonatomic,assign,readwrite) int32_t value;


@end


@implementation BROneIntSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_ONE_INT_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BROneIntSettingResult %p> value=0x%08X",
            self, self.value];
}

@end
