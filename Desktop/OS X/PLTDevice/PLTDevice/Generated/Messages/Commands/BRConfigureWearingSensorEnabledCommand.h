//
//  BRConfigureWearingSensorEnabledCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_WEARING_SENSOR_ENABLED 0x0216



@interface BRConfigureWearingSensorEnabledCommand : BRCommand

+ (BRConfigureWearingSensorEnabledCommand *)commandWithWearingStateSensorEnabled:(BOOL)wearingStateSensorEnabled;

@property(nonatomic,assign) BOOL wearingStateSensorEnabled;


@end
