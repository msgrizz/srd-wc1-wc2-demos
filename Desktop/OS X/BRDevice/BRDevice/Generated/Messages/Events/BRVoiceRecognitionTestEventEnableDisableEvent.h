//
//  BRVoiceRecognitionTestEventEnableDisableEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_VOICE_RECOGNITION_TEST_EVENT_ENABLEDISABLE_EVENT 0x100A



@interface BRVoiceRecognitionTestEventEnableDisableEvent : BREvent

@property(nonatomic,readonly) BOOL voiceRecognitionEventEnable;


@end
