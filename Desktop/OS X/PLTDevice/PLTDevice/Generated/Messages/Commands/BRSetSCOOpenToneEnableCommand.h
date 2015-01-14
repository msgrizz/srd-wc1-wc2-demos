//
//  BRSetSCOOpenToneEnableCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_SCO_OPEN_TONE_ENABLE 0x0408



@interface BRSetSCOOpenToneEnableCommand : BRCommand

+ (BRSetSCOOpenToneEnableCommand *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
