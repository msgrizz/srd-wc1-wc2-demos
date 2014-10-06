//
//  BRHalCurrentScenarioEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_HAL_CURRENT_SCENARIO_EVENT 0x1100



@interface BRHalCurrentScenarioEvent : BREvent

@property(nonatomic,readonly) uint16_t scenario;


@end
