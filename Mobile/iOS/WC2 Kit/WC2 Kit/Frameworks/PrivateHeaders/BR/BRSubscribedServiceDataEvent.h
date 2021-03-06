//
//  BRSubscribedServiceDataEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SUBSCRIBED_SERVICE_DATA_EVENT 0xFF0D



@interface BRSubscribedServiceDataEvent : BREvent

@property(nonatomic,readonly) uint16_t serviceID;
@property(nonatomic,readonly) uint16_t characteristic;
@property(nonatomic,readonly) NSData * serviceData;


@end
