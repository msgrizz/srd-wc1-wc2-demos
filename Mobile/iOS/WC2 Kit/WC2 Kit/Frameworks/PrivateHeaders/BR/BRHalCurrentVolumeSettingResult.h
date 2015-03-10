//
//  BRHalCurrentVolumeSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_HAL_CURRENT_VOLUME_SETTING_RESULT 0x1102



@interface BRHalCurrentVolumeSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t scenario;
@property(nonatomic,readonly) NSData * volumes;


@end
