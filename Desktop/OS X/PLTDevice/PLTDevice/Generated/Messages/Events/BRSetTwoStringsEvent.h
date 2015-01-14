//
//  BRSetTwoStringsEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_TWO_STRINGS_EVENT 0x0061



@interface BRSetTwoStringsEvent : BREvent

@property(nonatomic,readonly) NSString * firstValue;
@property(nonatomic,readonly) NSString * secondValue;


@end
