//
//  BRRawButtonTestEventEnableDisableCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_RAW_BUTTONTEST_EVENT_ENABLEDISABLE 0x1007



@interface BRRawButtonTestEventEnableDisableCommand : BRCommand

+ (BRRawButtonTestEventEnableDisableCommand *)commandWithRawButtonEventEnable:(BOOL)rawButtonEventEnable;

@property(nonatomic,assign) BOOL rawButtonEventEnable;


@end
