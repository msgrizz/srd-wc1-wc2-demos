//
//  BRSpeakerVolumeSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_SPEAKER_VOLUME_SETTING_RESULT 0x0E0A



@interface BRSpeakerVolumeSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t volumeValueType;
@property(nonatomic,readonly) int16_t volume;


@end
