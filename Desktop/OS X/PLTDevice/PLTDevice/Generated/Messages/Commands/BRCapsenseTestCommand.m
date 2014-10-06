//
//  BRCapsenseTestCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCapsenseTestCommand.h"
#import "BRMessage_Private.h"


const uint8_t CapsenseTestCommand_Command_resetDoffBaselines = 40;
const uint8_t CapsenseTestCommand_Command_enterTestMode = 48;
const uint8_t CapsenseTestCommand_Command_exitTestMode = 60;


@implementation BRCapsenseTestCommand

#pragma mark - Public

+ (BRCapsenseTestCommand *)commandWithCommand:(uint8_t)command
{
	BRCapsenseTestCommand *instance = [[BRCapsenseTestCommand alloc] init];
	instance.command = command;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CAPSENSE_TEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"command", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCapsenseTestCommand %p> command=0x%02X",
            self, self.command];
}

@end
