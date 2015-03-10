//
//  BRAALAcousticIncidentReportingThresholdsEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_EVENT 0x0F03



@interface BRAALAcousticIncidentReportingThresholdsEvent : BREvent

@property(nonatomic,readonly) uint8_t gainThreshold;
@property(nonatomic,readonly) uint16_t timeThreshold;


@end
