//
//  BRSetMobileVoiceCommandsCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_MOBILE_VOICE_COMMANDS 0x0F2C



@interface BRSetMobileVoiceCommandsCommand : BRCommand

+ (BRSetMobileVoiceCommandsCommand *)commandWithMobileVoiceCommands:(BOOL)mobileVoiceCommands;

@property(nonatomic,assign) BOOL mobileVoiceCommands;


@end
