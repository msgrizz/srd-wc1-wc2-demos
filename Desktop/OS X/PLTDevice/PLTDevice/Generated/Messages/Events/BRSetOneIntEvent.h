//
//  BRSetOneIntEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_ONE_INT_EVENT 0x0053



@interface BRSetOneIntEvent : BREvent

@property(nonatomic,readonly) int32_t value;


@end
