//
//  BRCapsenseTestCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CAPSENSE_TEST 0x101A

#define BRDefinedValue_CapsenseTestCommand_Command_resetDoffBaselines 40
#define BRDefinedValue_CapsenseTestCommand_Command_enterTestMode 48
#define BRDefinedValue_CapsenseTestCommand_Command_exitTestMode 60


@interface BRCapsenseTestCommand : BRCommand

+ (BRCapsenseTestCommand *)commandWithCommand:(uint8_t)command;

@property(nonatomic,assign) uint8_t command;


@end
