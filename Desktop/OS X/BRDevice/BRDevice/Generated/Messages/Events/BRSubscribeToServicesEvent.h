//
//  BRSubscribeToServicesEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SUBSCRIBE_TO_SERVICES_EVENT 0xFF0A



@interface BRSubscribeToServicesEvent : BREvent

@property(nonatomic,readonly) uint16_t serviceID;
@property(nonatomic,readonly) uint16_t characteristic;
@property(nonatomic,readonly) uint16_t mode;
@property(nonatomic,readonly) uint16_t period;


@end
