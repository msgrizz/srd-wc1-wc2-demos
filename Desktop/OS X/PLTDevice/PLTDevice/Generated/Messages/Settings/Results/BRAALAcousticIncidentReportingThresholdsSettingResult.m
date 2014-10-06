//
//  BRAALAcousticIncidentReportingThresholdsSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAALAcousticIncidentReportingThresholdsSettingResult.h"
#import "BRMessage_Private.h"




@interface BRAALAcousticIncidentReportingThresholdsSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t gainThreshold;
@property(nonatomic,assign,readwrite) uint16_t timeThreshold;


@end


@implementation BRAALAcousticIncidentReportingThresholdsSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"gainThreshold", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"timeThreshold", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAALAcousticIncidentReportingThresholdsSettingResult %p> gainThreshold=0x%02X, timeThreshold=0x%04X",
            self, self.gainThreshold, self.timeThreshold];
}

@end
