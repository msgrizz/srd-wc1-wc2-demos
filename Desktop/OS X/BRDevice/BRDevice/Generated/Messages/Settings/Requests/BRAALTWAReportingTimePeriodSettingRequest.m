//
//  BRAALTWAReportingTimePeriodSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAALTWAReportingTimePeriodSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRAALTWAReportingTimePeriodSettingRequest

#pragma BRSettingRequest

+ (BRAALTWAReportingTimePeriodSettingRequest *)request
{
	BRAALTWAReportingTimePeriodSettingRequest *instance = [[BRAALTWAReportingTimePeriodSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_TWA_REPORTING_TIME_PERIOD_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[

			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAALTWAReportingTimePeriodSettingRequest %p>",
            self];
}

@end
