//
//  BRConfigureSecondInboundCallRingTypeEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_EVENT 0x0404



@interface BRConfigureSecondInboundCallRingTypeEvent : BREvent

@property(nonatomic,readonly) uint8_t ringType;


@end
