//
//  BRAALTWAReportingEnableCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_AAL_TWA_REPORTING_ENABLE 0x0F07



@interface BRAALTWAReportingEnableCommand : BRCommand

+ (BRAALTWAReportingEnableCommand *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
