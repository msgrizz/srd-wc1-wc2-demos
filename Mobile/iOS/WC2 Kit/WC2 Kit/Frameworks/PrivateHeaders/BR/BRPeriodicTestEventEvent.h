//
//  BRPeriodicTestEventEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_PERIODIC_TEST_EVENT_EVENT 0x0004



@interface BRPeriodicTestEventEvent : BREvent

@property(nonatomic,readonly) int32_t time;
@property(nonatomic,readonly) NSData * byteArray;


@end
