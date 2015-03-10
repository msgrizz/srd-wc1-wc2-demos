//
//  BROLIFeatureEnableEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_OLI_FEATURE_ENABLE_EVENT 0x0409



@interface BROLIFeatureEnableEvent : BREvent

@property(nonatomic,readonly) uint8_t oLIenable;


@end
