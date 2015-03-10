//
//  BRAudioStatusEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_AUDIO_STATUS_EVENT 0x0E1E



@interface BRAudioStatusEvent : BREvent

@property(nonatomic,readonly) uint8_t codec;
@property(nonatomic,readonly) uint8_t port;
@property(nonatomic,readonly) uint8_t speakerGain;
@property(nonatomic,readonly) uint8_t micGain;


@end
