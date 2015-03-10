//
//  BRSetAudioBandwidthCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_AUDIO_BANDWIDTH 0x0F04

#define BRDefinedValue_SetAudioBandwidthCommand_Bandwidth_BandwidthNarrowband 1
#define BRDefinedValue_SetAudioBandwidthCommand_Bandwidth_BandwidthWideband 2


@interface BRSetAudioBandwidthCommand : BRCommand

+ (BRSetAudioBandwidthCommand *)commandWithInterfaceType:(uint8_t)interfaceType bandwidth:(uint8_t)bandwidth;

@property(nonatomic,assign) uint8_t interfaceType;
@property(nonatomic,assign) uint8_t bandwidth;


@end
