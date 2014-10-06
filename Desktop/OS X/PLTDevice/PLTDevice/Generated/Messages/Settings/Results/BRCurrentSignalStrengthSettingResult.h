//
//  BRCurrentSignalStrengthSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_CURRENT_SIGNAL_STRENGTH_SETTING_RESULT 0x0800



@interface BRCurrentSignalStrengthSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t connectionId;
@property(nonatomic,readonly) uint8_t strength;
@property(nonatomic,readonly) uint8_t nearFar;


@end
