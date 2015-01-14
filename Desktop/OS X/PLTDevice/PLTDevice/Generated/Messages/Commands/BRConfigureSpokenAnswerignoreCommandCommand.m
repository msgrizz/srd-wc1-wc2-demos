//
//  BRConfigureSpokenAnswerignoreCommandCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureSpokenAnswerignoreCommandCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureSpokenAnswerignoreCommandCommand

#pragma mark - Public

+ (BRConfigureSpokenAnswerignoreCommandCommand *)commandWithEnable:(BOOL)enable
{
	BRConfigureSpokenAnswerignoreCommandCommand *instance = [[BRConfigureSpokenAnswerignoreCommandCommand alloc] init];
	instance.enable = enable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_SPOKEN_ANSWERIGNORE_COMMAND;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"enable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureSpokenAnswerignoreCommandCommand %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
