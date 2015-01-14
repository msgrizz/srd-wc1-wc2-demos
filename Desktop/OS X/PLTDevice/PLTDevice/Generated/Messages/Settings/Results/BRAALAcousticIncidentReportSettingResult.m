//
//  BRAALAcousticIncidentReportSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAALAcousticIncidentReportSettingResult.h"
#import "BRMessage_Private.h"


@interface BRAALAcousticIncidentReportSettingResult ()



@end


@implementation BRAALAcousticIncidentReportSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_ACOUSTIC_INCIDENT_REPORT_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRAALAcousticIncidentReportSettingResult %p>",
            self];
}

@end
