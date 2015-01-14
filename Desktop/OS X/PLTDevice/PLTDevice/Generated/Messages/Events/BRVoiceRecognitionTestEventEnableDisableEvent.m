//
//  BRVoiceRecognitionTestEventEnableDisableEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRVoiceRecognitionTestEventEnableDisableEvent.h"
#import "BRMessage_Private.h"


@interface BRVoiceRecognitionTestEventEnableDisableEvent ()

@property(nonatomic,assign,readwrite) BOOL voiceRecognitionEventEnable;


@end


@implementation BRVoiceRecognitionTestEventEnableDisableEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOICE_RECOGNITION_TEST_EVENT_ENABLEDISABLE_EVENT;
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
    return [NSString stringWithFormat:@"<BRVoiceRecognitionTestEventEnableDisableEvent %p> voiceRecognitionEventEnable=%@",
            self, (self.voiceRecognitionEventEnable ? @"YES" : @"NO")];
}

@end
