//
//  BRAudioStatusSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_AUDIO_STATUS_SETTING_RESULT 0x0E1E



@interface BRAudioStatusSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t codec;
@property(nonatomic,readonly) uint8_t port;
@property(nonatomic,readonly) uint8_t speakerGain;
@property(nonatomic,readonly) uint8_t micGain;


@end
