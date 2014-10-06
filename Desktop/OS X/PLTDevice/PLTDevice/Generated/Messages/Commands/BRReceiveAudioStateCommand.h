//
//  BRReceiveAudioStateCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_RECEIVE_AUDIO_STATE 0x0E05



@interface BRReceiveAudioStateCommand : BRCommand

+ (BRReceiveAudioStateCommand *)commandWithState:(BOOL)state;

@property(nonatomic,assign) BOOL state;


@end
