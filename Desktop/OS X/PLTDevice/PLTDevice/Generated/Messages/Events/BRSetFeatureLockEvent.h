//
//  BRSetFeatureLockEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_FEATURE_LOCK_EVENT 0x0F12



@interface BRSetFeatureLockEvent : BREvent

@property(nonatomic,readonly) BOOL lock;
@property(nonatomic,readonly) NSData * commands;


@end
