//
//  BRBatteryExtendedInfoSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_BATTERY_EXTENDED_INFO_SETTING_RESULT 0x0A1B



@interface BRBatteryExtendedInfoSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t voltage;
@property(nonatomic,readonly) uint16_t remainingcapacity;
@property(nonatomic,readonly) int16_t current;
@property(nonatomic,readonly) uint8_t stateofcharge;
@property(nonatomic,readonly) uint8_t temperature;
@property(nonatomic,readonly) uint16_t totalcapacity;
@property(nonatomic,readonly) uint16_t totaltalktime;
@property(nonatomic,readonly) uint16_t numchargecycles;
@property(nonatomic,readonly) uint16_t numfullcharges;


@end
