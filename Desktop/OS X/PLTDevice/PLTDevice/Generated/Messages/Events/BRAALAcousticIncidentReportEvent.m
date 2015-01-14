//
//  BRAALAcousticIncidentReportEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAALAcousticIncidentReportEvent.h"
#import "BRMessage_Private.h"


@interface BRAALAcousticIncidentReportEvent ()

@property(nonatomic,assign,readwrite) uint8_t incidentType;
@property(nonatomic,assign,readwrite) uint32_t incidentDuration;
@property(nonatomic,assign,readwrite) uint8_t preLimiterSplEstimate;
@property(nonatomic,assign,readwrite) uint8_t gainReduction;


@end


@implementation BRAALAcousticIncidentReportEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_ACOUSTIC_INCIDENT_REPORT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"incidentType", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"incidentDuration", @"type": @(BRPayloadItemTypeUnsignedInt)},
			@{@"name": @"preLimiterSplEstimate", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"gainReduction", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAALAcousticIncidentReportEvent %p> incidentType=0x%02X, incidentDuration=0x%08X, preLimiterSplEstimate=0x%02X, gainReduction=0x%02X",
            self, self.incidentType, self.incidentDuration, self.preLimiterSplEstimate, self.gainReduction];
}

@end
