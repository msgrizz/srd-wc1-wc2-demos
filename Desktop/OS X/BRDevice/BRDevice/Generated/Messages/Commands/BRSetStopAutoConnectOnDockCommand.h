//
//  BRSetStopAutoConnectOnDockCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_STOP_AUTOCONNECT_ON_DOCK 0x0F22



@interface BRSetStopAutoConnectOnDockCommand : BRCommand

+ (BRSetStopAutoConnectOnDockCommand *)commandWithStopAutoConnect:(BOOL)stopAutoConnect;

@property(nonatomic,assign) BOOL stopAutoConnect;


@end
