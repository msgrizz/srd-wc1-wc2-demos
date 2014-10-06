//
//  BRSetMobileVoiceCommandsCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_MOBILE_VOICE_COMMANDS 0x0F2C



@interface BRSetMobileVoiceCommandsCommand : BRCommand

+ (BRSetMobileVoiceCommandsCommand *)commandWithMobileVoiceCommands:(BOOL)mobileVoiceCommands;

@property(nonatomic,assign) BOOL mobileVoiceCommands;


@end
