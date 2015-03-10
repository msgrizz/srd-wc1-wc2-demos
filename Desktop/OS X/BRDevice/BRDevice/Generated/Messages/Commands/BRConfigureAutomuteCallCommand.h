//
//  BRConfigureAutomuteCallCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_AUTOMUTE_CALL 0x0218



@interface BRConfigureAutomuteCallCommand : BRCommand

+ (BRConfigureAutomuteCallCommand *)commandWithAutoMuteCall:(BOOL)autoMuteCall;

@property(nonatomic,assign) BOOL autoMuteCall;


@end
