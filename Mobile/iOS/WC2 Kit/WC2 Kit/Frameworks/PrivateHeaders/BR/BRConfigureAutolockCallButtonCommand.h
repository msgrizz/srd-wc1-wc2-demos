//
//  BRConfigureAutolockCallButtonCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_AUTOLOCK_CALL_BUTTON 0x0210



@interface BRConfigureAutolockCallButtonCommand : BRCommand

+ (BRConfigureAutolockCallButtonCommand *)commandWithAutoLockCallButton:(BOOL)autoLockCallButton;

@property(nonatomic,assign) BOOL autoLockCallButton;


@end
