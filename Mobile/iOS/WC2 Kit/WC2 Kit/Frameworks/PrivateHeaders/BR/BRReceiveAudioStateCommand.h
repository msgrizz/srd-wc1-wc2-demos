//
//  BRReceiveAudioStateCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_RECEIVE_AUDIO_STATE 0x0E05



@interface BRReceiveAudioStateCommand : BRCommand

+ (BRReceiveAudioStateCommand *)commandWithState:(BOOL)state;

@property(nonatomic,assign) BOOL state;


@end
