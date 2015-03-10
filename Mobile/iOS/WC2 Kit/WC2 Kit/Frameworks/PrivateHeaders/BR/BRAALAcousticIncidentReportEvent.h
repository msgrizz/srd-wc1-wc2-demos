//
//  BRAALAcousticIncidentReportEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_AAL_ACOUSTIC_INCIDENT_REPORT_EVENT 0x0F05



@interface BRAALAcousticIncidentReportEvent : BREvent

@property(nonatomic,readonly) uint8_t incidentType;
@property(nonatomic,readonly) uint32_t incidentDuration;
@property(nonatomic,readonly) uint8_t preLimiterSplEstimate;
@property(nonatomic,readonly) uint8_t gainReduction;


@end
