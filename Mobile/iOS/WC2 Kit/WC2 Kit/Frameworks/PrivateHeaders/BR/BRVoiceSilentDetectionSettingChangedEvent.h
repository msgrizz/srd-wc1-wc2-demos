//
//  BRVoiceSilentDetectionSettingChangedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_VOICE_SILENT_DETECTION_SETTING_CHANGED_EVENT 0x0815



@interface BRVoiceSilentDetectionSettingChangedEvent : BREvent

@property(nonatomic,readonly) uint8_t mode;


@end
