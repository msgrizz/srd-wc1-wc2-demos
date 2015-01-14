//
//  BRServiceConfigurationChangedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SERVICE_CONFIGURATION_CHANGED_EVENT 0xFF00



@interface BRServiceConfigurationChangedEvent : BREvent

@property(nonatomic,readonly) uint16_t serviceID;
@property(nonatomic,readonly) uint16_t characteristic;
@property(nonatomic,readonly) NSData * configurationData;


@end
