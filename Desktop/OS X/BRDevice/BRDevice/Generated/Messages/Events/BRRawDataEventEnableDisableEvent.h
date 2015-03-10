//
//  BRRawDataEventEnableDisableEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_RAW_DATA_EVENT_ENABLEDISABLE_EVENT 0x100F



@interface BRRawDataEventEnableDisableEvent : BREvent

@property(nonatomic,readonly) BOOL rawDataEventEnable;


@end
