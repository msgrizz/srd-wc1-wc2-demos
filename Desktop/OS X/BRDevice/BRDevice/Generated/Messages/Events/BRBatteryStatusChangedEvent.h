//
//  BRBatteryStatusChangedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_BATTERY_STATUS_CHANGED_EVENT 0x0A1C



@interface BRBatteryStatusChangedEvent : BREvent

@property(nonatomic,readonly) uint8_t level;
@property(nonatomic,readonly) uint8_t numLevels;
@property(nonatomic,readonly) BOOL charging;
@property(nonatomic,readonly) uint16_t minutesOfTalkTime;
@property(nonatomic,readonly) BOOL talkTimeIsHighEstimate;


@end
