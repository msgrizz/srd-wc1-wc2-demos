//
//  BRMFITestCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_MFI_TEST 0x1018



@interface BRMFITestCommand : BRCommand

+ (BRMFITestCommand *)commandWithCommand:(uint8_t)command;

@property(nonatomic,assign) uint8_t command;


@end
