//
//  BRSetDefaultOutboundInterfaceEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_DEFAULT_OUTBOUND_INTERFACE_EVENT 0x0F08



@interface BRSetDefaultOutboundInterfaceEvent : BREvent

@property(nonatomic,readonly) uint8_t interfaceType;


@end
