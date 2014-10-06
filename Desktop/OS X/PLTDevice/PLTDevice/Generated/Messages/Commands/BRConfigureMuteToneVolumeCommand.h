//
//  BRConfigureMuteToneVolumeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_MUTE_TONE_VOLUME 0x0400

extern const uint8_t ConfigureMuteToneVolumeCommand_MuteToneVolume_VolumeOff;
extern const uint8_t ConfigureMuteToneVolumeCommand_MuteToneVolume_VolumeLow;
extern const uint8_t ConfigureMuteToneVolumeCommand_MuteToneVolume_VolumeStandard;


@interface BRConfigureMuteToneVolumeCommand : BRCommand

+ (BRConfigureMuteToneVolumeCommand *)commandWithMuteToneVolume:(uint8_t)muteToneVolume;

@property(nonatomic,assign) uint8_t muteToneVolume;


@end
