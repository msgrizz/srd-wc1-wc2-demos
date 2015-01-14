//
//  BRAALAcousticIncidentReportingThresholdsSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAALAcousticIncidentReportingThresholdsSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRAALAcousticIncidentReportingThresholdsSettingRequest

#pragma BRSettingRequest

+ (BRAALAcousticIncidentReportingThresholdsSettingRequest *)request
{
	BRAALAcousticIncidentReportingThresholdsSettingRequest *instance = [[BRAALAcousticIncidentReportingThresholdsSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRAALAcousticIncidentReportingThresholdsSettingRequest %p>",
            self];
}

@end
