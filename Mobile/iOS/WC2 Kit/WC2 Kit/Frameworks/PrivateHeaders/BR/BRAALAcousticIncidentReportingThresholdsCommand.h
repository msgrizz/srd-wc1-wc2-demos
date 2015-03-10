//
//  BRAALAcousticIncidentReportingThresholdsCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS 0x0F03



@interface BRAALAcousticIncidentReportingThresholdsCommand : BRCommand

+ (BRAALAcousticIncidentReportingThresholdsCommand *)commandWithGainThreshold:(uint8_t)gainThreshold timeThreshold:(uint16_t)timeThreshold;

@property(nonatomic,assign) uint8_t gainThreshold;
@property(nonatomic,assign) uint16_t timeThreshold;


@end
