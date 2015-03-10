//
//  BRTransmitAudioStateCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_TRANSMIT_AUDIO_STATE 0x0E03



@interface BRTransmitAudioStateCommand : BRCommand

+ (BRTransmitAudioStateCommand *)commandWithState:(BOOL)state;

@property(nonatomic,assign) BOOL state;


@end
