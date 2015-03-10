//
//  BRAALAcousticIncidentReportingThresholdsEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAALAcousticIncidentReportingThresholdsEvent.h"
#import "BRMessage_Private.h"


@interface BRAALAcousticIncidentReportingThresholdsEvent ()

@property(nonatomic,assign,readwrite) uint8_t gainThreshold;
@property(nonatomic,assign,readwrite) uint16_t timeThreshold;


@end


@implementation BRAALAcousticIncidentReportingThresholdsEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_EVENT;
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
    return [NSString stringWithFormat:@"<BRAALAcousticIncidentReportingThresholdsEvent %p> gainThreshold=0x%02X, timeThreshold=0x%04X",
            self, self.gainThreshold, self.timeThreshold];
}

@end
