//
//  BRGetMuteToneVolumeSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_GET_MUTE_TONE_VOLUME_SETTING_RESULT 0x0402



@interface BRGetMuteToneVolumeSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t muteToneVolume;


@end
