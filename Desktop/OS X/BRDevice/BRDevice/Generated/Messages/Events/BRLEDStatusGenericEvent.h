//
//  BRLEDStatusGenericEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_LED_STATUS_GENERIC_EVENT 0x0E07



@interface BRLEDStatusGenericEvent : BREvent

@property(nonatomic,readonly) NSData * iD;
@property(nonatomic,readonly) NSData * color;
@property(nonatomic,readonly) NSData * state;


@end
