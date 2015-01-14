//
//  BRHeadsetCallStatusEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_HEADSET_CALL_STATUS_EVENT 0x0E22



@interface BRHeadsetCallStatusEvent : BREvent

@property(nonatomic,readonly) uint16_t numberOfDevices;
@property(nonatomic,readonly) uint8_t connectionId;
@property(nonatomic,readonly) uint8_t state;
@property(nonatomic,readonly) NSString * number;
@property(nonatomic,readonly) NSString * name;


@end
