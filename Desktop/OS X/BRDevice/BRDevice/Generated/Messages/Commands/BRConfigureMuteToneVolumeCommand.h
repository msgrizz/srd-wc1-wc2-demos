//
//  BRConfigureMuteToneVolumeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_MUTE_TONE_VOLUME 0x0400

#define BRDefinedValue_ConfigureMuteToneVolumeCommand_MuteToneVolume_VolumeOff 0
#define BRDefinedValue_ConfigureMuteToneVolumeCommand_MuteToneVolume_VolumeLow 1
#define BRDefinedValue_ConfigureMuteToneVolumeCommand_MuteToneVolume_VolumeStandard 2


@interface BRConfigureMuteToneVolumeCommand : BRCommand

+ (BRConfigureMuteToneVolumeCommand *)commandWithMuteToneVolume:(uint8_t)muteToneVolume;

@property(nonatomic,assign) uint8_t muteToneVolume;


@end
