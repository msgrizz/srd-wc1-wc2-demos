//
//  BRTestInterfaceEnableDisableEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_TEST_INTERFACE_ENABLEDISABLE_EVENT 0x1000



@interface BRTestInterfaceEnableDisableEvent : BREvent

@property(nonatomic,readonly) BOOL testInterfaceEnable;


@end
