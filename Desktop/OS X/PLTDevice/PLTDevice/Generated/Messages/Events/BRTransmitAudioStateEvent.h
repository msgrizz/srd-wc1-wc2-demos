//
//  BRTransmitAudioStateEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_TRANSMIT_AUDIO_STATE_EVENT 0x0E03



@interface BRTransmitAudioStateEvent : BREvent

@property(nonatomic,readonly) BOOL state;


@end
