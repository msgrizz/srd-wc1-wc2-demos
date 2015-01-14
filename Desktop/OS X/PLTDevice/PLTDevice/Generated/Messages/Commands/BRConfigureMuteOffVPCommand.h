//
//  BRConfigureMuteOffVPCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_MUTE_OFF_VP 0x0407



@interface BRConfigureMuteOffVPCommand : BRCommand

+ (BRConfigureMuteOffVPCommand *)commandWithEnable:(BOOL)enable;

@property(nonatomic,assign) BOOL enable;


@end
