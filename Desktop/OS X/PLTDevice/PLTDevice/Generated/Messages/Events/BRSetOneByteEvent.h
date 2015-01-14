//
//  BRSetOneByteEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_ONE_BYTE_EVENT 0x0051



@interface BRSetOneByteEvent : BREvent

@property(nonatomic,readonly) uint8_t value;


@end
