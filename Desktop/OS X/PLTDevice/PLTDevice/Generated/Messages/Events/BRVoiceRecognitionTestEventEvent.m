//
//  BRVoiceRecognitionTestEventEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRVoiceRecognitionTestEventEvent.h"
#import "BRMessage_Private.h"




@interface BRVoiceRecognitionTestEventEvent ()

@property(nonatomic,assign,readwrite) int16_t voiceRecognitonId;


@end


@implementation BRVoiceRecognitionTestEventEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOICE_RECOGNITION_TEST_EVENT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"voiceRecognitonId", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRVoiceRecognitionTestEventEvent %p> voiceRecognitonId=0x%04X",
            self, self.voiceRecognitonId];
}

@end
