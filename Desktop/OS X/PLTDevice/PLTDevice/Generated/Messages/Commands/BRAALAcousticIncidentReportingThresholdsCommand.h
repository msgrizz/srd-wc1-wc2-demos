//
//  BRAALAcousticIncidentReportingThresholdsCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS 0x0F03



@interface BRAALAcousticIncidentReportingThresholdsCommand : BRCommand

+ (BRAALAcousticIncidentReportingThresholdsCommand *)commandWithGainThreshold:(uint8_t)gainThreshold timeThreshold:(uint16_t)timeThreshold;

@property(nonatomic,assign) uint8_t gainThreshold;
@property(nonatomic,assign) uint16_t timeThreshold;


@end
