//
//  BRVoiceRecognitionTestEventEnableDisableCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_VOICE_RECOGNITION_TEST_EVENT_ENABLEDISABLE 0x100A



@interface BRVoiceRecognitionTestEventEnableDisableCommand : BRCommand

+ (BRVoiceRecognitionTestEventEnableDisableCommand *)commandWithVoiceRecogntionEventEnable:(BOOL)voiceRecogntionEventEnable;

@property(nonatomic,assign) BOOL voiceRecogntionEventEnable;


@end
