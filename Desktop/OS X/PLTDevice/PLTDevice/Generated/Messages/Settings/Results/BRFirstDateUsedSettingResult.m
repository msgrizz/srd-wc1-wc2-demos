//
//  BRFirstDateUsedSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRFirstDateUsedSettingResult.h"
#import "BRMessage_Private.h"


@interface BRFirstDateUsedSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t month;
@property(nonatomic,assign,readwrite) uint16_t day;
@property(nonatomic,assign,readwrite) uint32_t year;


@end


@implementation BRFirstDateUsedSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FIRST_DATE_USED_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"month", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"day", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"year", @"type": @(BRPayloadItemTypeUnsignedInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRFirstDateUsedSettingResult %p> month=0x%04X, day=0x%04X, year=0x%08X",
            self, self.month, self.day, self.year];
}

@end
