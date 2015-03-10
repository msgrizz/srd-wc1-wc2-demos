//
//  BRSetAudioTransmitGainCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetAudioTransmitGainCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetAudioTransmitGainCommand

#pragma mark - Public

+ (BRSetAudioTransmitGainCommand *)commandWithGain:(uint8_t)gain
{
	BRSetAudioTransmitGainCommand *instance = [[BRSetAudioTransmitGainCommand alloc] init];
	instance.gain = gain;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_AUDIO_TRANSMIT_GAIN;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"gain", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetAudioTransmitGainCommand %p> gain=0x%02X",
            self, self.gain];
}

@end
