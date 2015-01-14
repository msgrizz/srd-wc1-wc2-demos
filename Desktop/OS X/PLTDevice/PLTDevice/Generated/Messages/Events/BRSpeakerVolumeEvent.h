//
//  BRSpeakerVolumeEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SPEAKER_VOLUME_EVENT 0x0E0A



@interface BRSpeakerVolumeEvent : BREvent

@property(nonatomic,readonly) uint8_t volumeValueType;
@property(nonatomic,readonly) int16_t volume;


@end
