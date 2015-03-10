//
//  BRSetAutoConnectToMobileCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_AUTOCONNECT_TO_MOBILE 0x0F20



@interface BRSetAutoConnectToMobileCommand : BRCommand

+ (BRSetAutoConnectToMobileCommand *)commandWithAutoConnect:(BOOL)autoConnect;

@property(nonatomic,assign) BOOL autoConnect;


@end
