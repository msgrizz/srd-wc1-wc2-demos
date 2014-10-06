//
//  BRCapsenseTestCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CAPSENSE_TEST 0x101A

extern const uint8_t CapsenseTestCommand_Command_resetDoffBaselines;
extern const uint8_t CapsenseTestCommand_Command_enterTestMode;
extern const uint8_t CapsenseTestCommand_Command_exitTestMode;


@interface BRCapsenseTestCommand : BRCommand

+ (BRCapsenseTestCommand *)commandWithCommand:(uint8_t)command;

@property(nonatomic,assign) uint8_t command;


@end
