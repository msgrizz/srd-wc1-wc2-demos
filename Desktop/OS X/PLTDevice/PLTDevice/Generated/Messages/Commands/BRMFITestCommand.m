//
//  BRMFITestCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMFITestCommand.h"
#import "BRMessage_Private.h"


@implementation BRMFITestCommand

#pragma mark - Public

+ (BRMFITestCommand *)commandWithCommand:(uint8_t)command
{
	BRMFITestCommand *instance = [[BRMFITestCommand alloc] init];
	instance.command = command;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MFI_TEST;
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
    return [NSString stringWithFormat:@"<BRMFITestCommand %p> command=0x%02X",
            self, self.command];
}

@end
