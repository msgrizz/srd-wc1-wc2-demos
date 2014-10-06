//
//  BRSetSpeakerVolumeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_SPEAKER_VOLUME 0x0E0A

extern const uint8_t SetSpeakerVolumeCommand_Action_SpeakerVolumeRelativeUpDown;
extern const uint8_t SetSpeakerVolumeCommand_Action_SpeakerVolumeAbsolutePercentage;
extern const uint8_t SetSpeakerVolumeCommand_Action_SpeakerVolumeAbsoluteDb;
extern const uint8_t SetSpeakerVolumeCommand_Action_SpeakerVolumeQ8dot8Format;


@interface BRSetSpeakerVolumeCommand : BRCommand

+ (BRSetSpeakerVolumeCommand *)commandWithAction:(uint8_t)action volume:(int16_t)volume;

@property(nonatomic,assign) uint8_t action;
@property(nonatomic,assign) int16_t volume;


@end
