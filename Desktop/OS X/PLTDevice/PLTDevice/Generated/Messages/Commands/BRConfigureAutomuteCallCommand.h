//
//  BRConfigureAutomuteCallCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_AUTOMUTE_CALL 0x0218



@interface BRConfigureAutomuteCallCommand : BRCommand

+ (BRConfigureAutomuteCallCommand *)commandWithAutoMuteCall:(BOOL)autoMuteCall;

@property(nonatomic,assign) BOOL autoMuteCall;


@end
