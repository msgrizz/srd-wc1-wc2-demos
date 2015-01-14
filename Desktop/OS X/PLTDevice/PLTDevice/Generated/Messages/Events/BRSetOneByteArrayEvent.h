//
//  BRSetOneByteArrayEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_ONE_BYTE_ARRAY_EVENT 0x0057



@interface BRSetOneByteArrayEvent : BREvent

@property(nonatomic,readonly) NSData * value;


@end
