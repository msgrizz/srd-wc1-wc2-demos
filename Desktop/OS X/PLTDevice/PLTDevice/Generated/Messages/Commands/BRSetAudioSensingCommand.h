//
//  BRSetAudioSensingCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_AUDIO_SENSING 0x0F1C



@interface BRSetAudioSensingCommand : BRCommand

+ (BRSetAudioSensingCommand *)commandWithAudioSensing:(BOOL)audioSensing;

@property(nonatomic,assign) BOOL audioSensing;


@end
