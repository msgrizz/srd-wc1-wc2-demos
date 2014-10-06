//
//  BRMicrophoneMuteStateEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_MICROPHONE_MUTE_STATE_EVENT 0x0E01



@interface BRMicrophoneMuteStateEvent : BREvent

@property(nonatomic,readonly) BOOL state;


@end
