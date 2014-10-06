//
//  BRSetAudioSensingCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetAudioSensingCommand.h"
#import "BRMessage_Private.h"




@implementation BRSetAudioSensingCommand

#pragma mark - Public

+ (BRSetAudioSensingCommand *)commandWithAudioSensing:(BOOL)audioSensing
{
	BRSetAudioSensingCommand *instance = [[BRSetAudioSensingCommand alloc] init];
	instance.audioSensing = audioSensing;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_AUDIO_SENSING;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"audioSensing", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetAudioSensingCommand %p> audioSensing=%@",
            self, (self.audioSensing ? @"YES" : @"NO")];
}

@end
