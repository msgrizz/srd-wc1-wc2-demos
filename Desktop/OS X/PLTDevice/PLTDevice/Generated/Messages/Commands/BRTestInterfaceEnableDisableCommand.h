//
//  BRTestInterfaceEnableDisableCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_TEST_INTERFACE_ENABLEDISABLE 0x1000



@interface BRTestInterfaceEnableDisableCommand : BRCommand

+ (BRTestInterfaceEnableDisableCommand *)commandWithTestInterfaceEnable:(BOOL)testInterfaceEnable;

@property(nonatomic,assign) BOOL testInterfaceEnable;


@end
