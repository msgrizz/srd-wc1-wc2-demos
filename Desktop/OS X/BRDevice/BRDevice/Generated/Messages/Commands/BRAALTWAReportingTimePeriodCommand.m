//
//  BRAALTWAReportingTimePeriodCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAALTWAReportingTimePeriodCommand.h"
#import "BRMessage_Private.h"


@implementation BRAALTWAReportingTimePeriodCommand

#pragma mark - Public

+ (BRAALTWAReportingTimePeriodCommand *)commandWithTimePeriod:(uint32_t)timePeriod
{
	BRAALTWAReportingTimePeriodCommand *instance = [[BRAALTWAReportingTimePeriodCommand alloc] init];
	instance.timePeriod = timePeriod;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_TWA_REPORTING_TIME_PERIOD;
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
    return [NSString stringWithFormat:@"<BRAALTWAReportingTimePeriodCommand %p> timePeriod=0x%08X",
            self, self.timePeriod];
}

@end
