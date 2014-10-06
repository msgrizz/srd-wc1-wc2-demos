//
//  BRMicrophoneMuteStateCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_MICROPHONE_MUTE_STATE 0x0E01



@interface BRMicrophoneMuteStateCommand : BRCommand

+ (BRMicrophoneMuteStateCommand *)commandWithState:(BOOL)state;

@property(nonatomic,assign) BOOL state;


@end
