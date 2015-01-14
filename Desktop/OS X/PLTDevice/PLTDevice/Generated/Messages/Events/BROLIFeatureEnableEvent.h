//
//  BROLIFeatureEnableEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_OLI_FEATURE_ENABLE_EVENT 0x0409



@interface BROLIFeatureEnableEvent : BREvent

@property(nonatomic,readonly) uint8_t oLIenable;


@end
