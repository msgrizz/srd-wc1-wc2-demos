//
//  BRSetSpeakerVolumeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_SPEAKER_VOLUME 0x0E0A

#define BRDefinedValue_SetSpeakerVolumeCommand_Action_SpeakerVolumeRelativeUpDown 0x00
#define BRDefinedValue_SetSpeakerVolumeCommand_Action_SpeakerVolumeAbsolutePercentage 0x01
#define BRDefinedValue_SetSpeakerVolumeCommand_Action_SpeakerVolumeAbsoluteDb 0x02
#define BRDefinedValue_SetSpeakerVolumeCommand_Action_SpeakerVolumeQ8dot8Format 0x03


@interface BRSetSpeakerVolumeCommand : BRCommand

+ (BRSetSpeakerVolumeCommand *)commandWithAction:(uint8_t)action volume:(int16_t)volume;

@property(nonatomic,assign) uint8_t action;
@property(nonatomic,assign) int16_t volume;


@end
