//
//  BRBatteryInfoSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_BATTERY_INFO_SETTING_RESULT 0x0A1A



@interface BRBatteryInfoSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t level;
@property(nonatomic,readonly) uint8_t numLevels;
@property(nonatomic,readonly) BOOL charging;
@property(nonatomic,readonly) uint16_t minutesOfTalkTime;
@property(nonatomic,readonly) BOOL talkTimeIsHighEstimate;


@end
