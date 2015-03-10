//
//  BRIllegalValueException.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRException.h"


#define BR_ILLEGAL_VALUE_EXCEPTION 0x0808



@interface BRIllegalValueException : BRException

@property(nonatomic,readonly) int32_t value;


@end
