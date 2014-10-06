//
//  BRFirstDateUsedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_FIRST_DATE_USED_EVENT 0x0A07



@interface BRFirstDateUsedEvent : BREvent

@property(nonatomic,readonly) uint16_t month;
@property(nonatomic,readonly) uint16_t day;
@property(nonatomic,readonly) uint32_t year;


@end
