//
//  BRAALAcousticIncidentReportingThresholdsCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAALAcousticIncidentReportingThresholdsCommand.h"
#import "BRMessage_Private.h"


@implementation BRAALAcousticIncidentReportingThresholdsCommand

#pragma mark - Public

+ (BRAALAcousticIncidentReportingThresholdsCommand *)commandWithGainThreshold:(uint8_t)gainThreshold timeThreshold:(uint16_t)timeThreshold
{
	BRAALAcousticIncidentReportingThresholdsCommand *instance = [[BRAALAcousticIncidentReportingThresholdsCommand alloc] init];
	instance.gainThreshold = gainThreshold;
	instance.timeThreshold = timeThreshold;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS;
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
    return [NSString stringWithFormat:@"<BRAALAcousticIncidentReportingThresholdsCommand %p> gainThreshold=0x%02X, timeThreshold=0x%04X",
            self, self.gainThreshold, self.timeThreshold];
}

@end
