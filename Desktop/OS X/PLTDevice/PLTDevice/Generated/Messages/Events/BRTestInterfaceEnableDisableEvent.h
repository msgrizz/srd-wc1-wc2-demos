//
//  BRTestInterfaceEnableDisableEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_TEST_INTERFACE_ENABLEDISABLE_EVENT 0x1000



@interface BRTestInterfaceEnableDisableEvent : BREvent

@property(nonatomic,readonly) BOOL testInterfaceEnable;


@end
