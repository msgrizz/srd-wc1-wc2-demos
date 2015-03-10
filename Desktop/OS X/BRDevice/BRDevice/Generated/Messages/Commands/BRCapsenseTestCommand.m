//
//  BRCapsenseTestCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCapsenseTestCommand.h"
#import "BRMessage_Private.h"


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
