//
//  BRHalCurrentVolumeSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_HAL_CURRENT_VOLUME_SETTING_RESULT 0x1102



@interface BRHalCurrentVolumeSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t scenario;
@property(nonatomic,readonly) NSData * volumes;


@end
