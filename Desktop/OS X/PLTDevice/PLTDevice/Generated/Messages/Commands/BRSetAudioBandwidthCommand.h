//
//  BRSetAudioBandwidthCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_AUDIO_BANDWIDTH 0x0F04

extern const uint8_t SetAudioBandwidthCommand_Bandwidth_BandwidthNarrowband;
extern const uint8_t SetAudioBandwidthCommand_Bandwidth_BandwidthWideband;


@interface BRSetAudioBandwidthCommand : BRCommand

+ (BRSetAudioBandwidthCommand *)commandWithInterfaceType:(uint8_t)interfaceType bandwidth:(uint8_t)bandwidth;

@property(nonatomic,assign) uint8_t interfaceType;
@property(nonatomic,assign) uint8_t bandwidth;


@end
