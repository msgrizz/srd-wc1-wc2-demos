//
//  BRWearingStateChangedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_WEARING_STATE_CHANGED_EVENT 0x0200



@interface BRWearingStateChangedEvent : BREvent

@property(nonatomic,readonly) BOOL worn;


@end
