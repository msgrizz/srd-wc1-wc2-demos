//
//  BRConfigureLyncDialToneOnCallPressCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS 0x0A32



@interface BRConfigureLyncDialToneOnCallPressCommand : BRCommand

+ (BRConfigureLyncDialToneOnCallPressCommand *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
