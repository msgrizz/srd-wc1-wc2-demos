//
//  BRTextToSpeechTestCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTextToSpeechTestCommand.h"
#import "BRMessage_Private.h"


@implementation BRTextToSpeechTestCommand

#pragma mark - Public

+ (BRTextToSpeechTestCommand *)commandWithText:(NSString *)text
{
	BRTextToSpeechTestCommand *instance = [[BRTextToSpeechTestCommand alloc] init];
	instance.text = text;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TEXT_TO_SPEECH_TEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"text", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTextToSpeechTestCommand %p> text=%@",
            self, self.text];
}

@end
