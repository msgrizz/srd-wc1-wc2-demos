//
//  BRTimeweightedAveragePeriodSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTimeweightedAveragePeriodSettingResult.h"
#import "BRMessage_Private.h"




@interface BRTimeweightedAveragePeriodSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t twa;


@end


@implementation BRTimeweightedAveragePeriodSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TIMEWEIGHTED_AVERAGE_PERIOD_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"twa", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTimeweightedAveragePeriodSettingResult %p> twa=0x%02X",
            self, self.twa];
}

@end
