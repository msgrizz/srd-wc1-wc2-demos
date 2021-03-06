//
//  BRAALTWAReportingTimePeriodSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAALTWAReportingTimePeriodSettingResult.h"
#import "BRMessage_Private.h"


@interface BRAALTWAReportingTimePeriodSettingResult ()

@property(nonatomic,assign,readwrite) uint32_t timePeriod;


@end


@implementation BRAALTWAReportingTimePeriodSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_TWA_REPORTING_TIME_PERIOD_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"timePeriod", @"type": @(BRPayloadItemTypeUnsignedInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAALTWAReportingTimePeriodSettingResult %p> timePeriod=0x%08X",
            self, self.timePeriod];
}

@end
