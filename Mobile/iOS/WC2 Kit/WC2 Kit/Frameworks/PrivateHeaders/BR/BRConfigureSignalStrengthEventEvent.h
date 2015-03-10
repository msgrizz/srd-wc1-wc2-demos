//
//  BRConfigureSignalStrengthEventEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CONFIGURE_SIGNAL_STRENGTH_EVENT_EVENT 0x0800



@interface BRConfigureSignalStrengthEventEvent : BREvent

@property(nonatomic,readonly) uint8_t connectionId;
@property(nonatomic,readonly) BOOL enable;
@property(nonatomic,readonly) BOOL dononly;
@property(nonatomic,readonly) BOOL trend;
@property(nonatomic,readonly) BOOL reportRssiAudio;
@property(nonatomic,readonly) BOOL reportNearFarAudio;
@property(nonatomic,readonly) BOOL reportNearFarToBase;
@property(nonatomic,readonly) uint8_t sensitivity;
@property(nonatomic,readonly) uint8_t nearThreshold;
@property(nonatomic,readonly) int16_t maxTimeout;


@end
