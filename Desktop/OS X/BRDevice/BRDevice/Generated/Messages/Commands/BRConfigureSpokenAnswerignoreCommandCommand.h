//
//  BRConfigureSpokenAnswerignoreCommandCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_SPOKEN_ANSWERIGNORE_COMMAND 0x0A2E



@interface BRConfigureSpokenAnswerignoreCommandCommand : BRCommand

+ (BRConfigureSpokenAnswerignoreCommandCommand *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
