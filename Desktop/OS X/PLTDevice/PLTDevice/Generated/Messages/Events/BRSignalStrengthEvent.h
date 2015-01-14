//
//  BRSignalStrengthEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SIGNAL_STRENGTH_EVENT 0x0806



@interface BRSignalStrengthEvent : BREvent

@property(nonatomic,readonly) uint8_t connectionId;
@property(nonatomic,readonly) uint8_t strength;
@property(nonatomic,readonly) uint8_t nearFar;


@end
