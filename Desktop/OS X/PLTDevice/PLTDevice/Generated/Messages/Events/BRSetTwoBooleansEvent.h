//
//  BRSetTwoBooleansEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_TWO_BOOLEANS_EVENT 0x0060



@interface BRSetTwoBooleansEvent : BREvent

@property(nonatomic,readonly) BOOL firstValue;
@property(nonatomic,readonly) BOOL secondValue;


@end
