//
//  BRPassThroughProtocolEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/30/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_PASS_THROUGH_PROTOCOL_EVENT 0xFF0F



@interface BRPassThroughProtocolEvent : BREvent

@property(nonatomic,readonly) uint16_t protocolID;
@property(nonatomic,readonly) NSData * _data;


@end
