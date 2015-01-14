//
//  BRSetMobileVoiceCommandsCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetMobileVoiceCommandsCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetMobileVoiceCommandsCommand

#pragma mark - Public

+ (BRSetMobileVoiceCommandsCommand *)commandWithMobileVoiceCommands:(BOOL)mobileVoiceCommands
{
	BRSetMobileVoiceCommandsCommand *instance = [[BRSetMobileVoiceCommandsCommand alloc] init];
	instance.mobileVoiceCommands = mobileVoiceCommands;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_MOBILE_VOICE_COMMANDS;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"mobileVoiceCommands", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetMobileVoiceCommandsCommand %p> mobileVoiceCommands=%@",
            self, (self.mobileVoiceCommands ? @"YES" : @"NO")];
}

@end
