//
//  BRVoiceRecognitionTestEventEnableDisableCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRVoiceRecognitionTestEventEnableDisableCommand.h"
#import "BRMessage_Private.h"




@implementation BRVoiceRecognitionTestEventEnableDisableCommand

#pragma mark - Public

+ (BRVoiceRecognitionTestEventEnableDisableCommand *)commandWithVoiceRecogntionEventEnable:(BOOL)voiceRecogntionEventEnable
{
	BRVoiceRecognitionTestEventEnableDisableCommand *instance = [[BRVoiceRecognitionTestEventEnableDisableCommand alloc] init];
	instance.voiceRecogntionEventEnable = voiceRecogntionEventEnable;
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
			@{@"name": @"voiceRecogntionEventEnable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRVoiceRecognitionTestEventEnableDisableCommand %p> voiceRecogntionEventEnable=%@",
            self, (self.voiceRecogntionEventEnable ? @"YES" : @"NO")];
}

@end
