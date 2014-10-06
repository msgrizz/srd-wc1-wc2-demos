//
//  BRHalEQChangedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_HAL_EQ_CHANGED_EVENT 0x1104



@interface BRHalEQChangedEvent : BREvent

@property(nonatomic,readonly) uint16_t scenario;
@property(nonatomic,readonly) uint16_t numberOfEQs;
@property(nonatomic,readonly) uint8_t eQId;
@property(nonatomic,readonly) NSData * eQSettings;


@end
