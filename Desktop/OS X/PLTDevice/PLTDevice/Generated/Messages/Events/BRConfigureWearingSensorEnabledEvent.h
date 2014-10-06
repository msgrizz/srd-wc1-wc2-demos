//
//  BRConfigureWearingSensorEnabledEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CONFIGURE_WEARING_SENSOR_ENABLED_EVENT 0x0216



@interface BRConfigureWearingSensorEnabledEvent : BREvent

@property(nonatomic,readonly) BOOL wearingStateSensorEnabled;


@end
