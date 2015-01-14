//
//  BRSignalStrengthConfigurationSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_SIGNAL_STRENGTH_CONFIGURATION_SETTING_RESULT 0x0806



@interface BRSignalStrengthConfigurationSettingResult : BRSettingResult

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
