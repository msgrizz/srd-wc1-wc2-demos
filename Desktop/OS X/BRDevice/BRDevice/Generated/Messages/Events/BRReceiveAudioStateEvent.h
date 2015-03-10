//
//  BRReceiveAudioStateEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_RECEIVE_AUDIO_STATE_EVENT 0x0E05



@interface BRReceiveAudioStateEvent : BREvent

@property(nonatomic,readonly) BOOL state;


@end
