//
//  BRSetOneShortEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_ONE_SHORT_EVENT 0x0052



@interface BRSetOneShortEvent : BREvent

@property(nonatomic,readonly) int16_t value;


@end
