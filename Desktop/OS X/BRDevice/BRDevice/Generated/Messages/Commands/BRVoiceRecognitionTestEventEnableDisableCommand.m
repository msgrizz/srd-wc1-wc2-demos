//
//  BRVoiceRecognitionTestEventEnableDisableCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRVoiceRecognitionTestEventEnableDisableCommand.h"
#import "BRMessage_Private.h"


@implementation BRVoiceRecognitionTestEventEnableDisableCommand

#pragma mark - Public

+ (BRVoiceRecognitionTestEventEnableDisableCommand *)commandWithVoiceRecognitionEventEnable:(BOOL)voiceRecognitionEventEnable
{
	BRVoiceRecognitionTestEventEnableDisableCommand *instance = [[BRVoiceRecognitionTestEventEnableDisableCommand alloc] init];
	instance.voiceRecognitionEventEnable = voiceRecognitionEventEnable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOICE_RECOGNITION_TEST_EVENT_ENABLEDISABLE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"voiceRecognitionEventEnable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRVoiceRecognitionTestEventEnableDisableCommand %p> voiceRecognitionEventEnable=%@",
            self, (self.voiceRecognitionEventEnable ? @"YES" : @"NO")];
}

@end
