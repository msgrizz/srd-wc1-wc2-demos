//
//  BRConfigureWearingSensorEnabledCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_WEARING_SENSOR_ENABLED 0x0216



@interface BRConfigureWearingSensorEnabledCommand : BRCommand

+ (BRConfigureWearingSensorEnabledCommand *)commandWithWearingStateSensorEnabled:(BOOL)wearingStateSensorEnabled;

@property(nonatomic,assign) BOOL wearingStateSensorEnabled;


@end
