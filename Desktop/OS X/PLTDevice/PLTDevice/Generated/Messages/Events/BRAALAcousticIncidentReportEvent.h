//
//  BRAALAcousticIncidentReportEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_AAL_ACOUSTIC_INCIDENT_REPORT_EVENT 0x0F05



@interface BRAALAcousticIncidentReportEvent : BREvent

@property(nonatomic,readonly) uint8_t incidentType;
@property(nonatomic,readonly) uint32_t incidentDuration;
@property(nonatomic,readonly) uint8_t preLimiterSplEstimate;
@property(nonatomic,readonly) uint8_t gainReduction;


@end
