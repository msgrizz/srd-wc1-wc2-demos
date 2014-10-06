//
//  BRApplicationConfigurationChangedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_APPLICATION_CONFIGURATION_CHANGED_EVENT 0xFF02



@interface BRApplicationConfigurationChangedEvent : BREvent

@property(nonatomic,readonly) uint16_t featureID;
@property(nonatomic,readonly) uint16_t characteristic;
@property(nonatomic,readonly) NSData * configurationData;


@end
