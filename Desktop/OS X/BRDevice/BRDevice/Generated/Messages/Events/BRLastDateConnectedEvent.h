//
//  BRLastDateConnectedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_LAST_DATE_CONNECTED_EVENT 0x0A0B



@interface BRLastDateConnectedEvent : BREvent

@property(nonatomic,readonly) uint16_t month;
@property(nonatomic,readonly) uint16_t day;
@property(nonatomic,readonly) uint32_t year;


@end
