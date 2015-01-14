//
//  BRSetStopAutoConnectOnDockCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_STOP_AUTOCONNECT_ON_DOCK 0x0F22



@interface BRSetStopAutoConnectOnDockCommand : BRCommand

+ (BRSetStopAutoConnectOnDockCommand *)commandWithStopAutoConnect:(BOOL)stopAutoConnect;

@property(nonatomic,assign) BOOL stopAutoConnect;


@end
