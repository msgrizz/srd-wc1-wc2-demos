//
//  BRSetAudioTransmitGainCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_AUDIO_TRANSMIT_GAIN 0x0E08



@interface BRSetAudioTransmitGainCommand : BRCommand

+ (BRSetAudioTransmitGainCommand *)commandWithGain:(uint8_t)gain;

@property(nonatomic,assign) uint8_t gain;


@end
