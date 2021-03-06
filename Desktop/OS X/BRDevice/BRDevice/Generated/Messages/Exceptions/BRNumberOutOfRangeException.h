//
//  BRNumberOutOfRangeException.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRException.h"


#define BR_NUMBER_OUT_OF_RANGE_EXCEPTION 0x0806



@interface BRNumberOutOfRangeException : BRException

@property(nonatomic,readonly) int32_t minimum;
@property(nonatomic,readonly) int32_t maximum;


@end
