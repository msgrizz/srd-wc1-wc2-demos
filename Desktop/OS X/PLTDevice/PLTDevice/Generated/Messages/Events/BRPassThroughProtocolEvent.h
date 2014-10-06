//
//  BRPassThroughProtocolEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_PASS_THROUGH_PROTOCOL_EVENT 0xFF0F



@interface BRPassThroughProtocolEvent : BREvent

@property(nonatomic,readonly) uint16_t protocolID;
@property(nonatomic,readonly) NSData * data;


@end
