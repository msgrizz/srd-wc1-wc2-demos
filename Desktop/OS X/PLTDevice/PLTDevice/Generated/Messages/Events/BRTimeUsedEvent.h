//
//  BRTimeUsedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_TIME_USED_EVENT 0x0A0D



@interface BRTimeUsedEvent : BREvent

@property(nonatomic,readonly) uint16_t totalTime;


@end
