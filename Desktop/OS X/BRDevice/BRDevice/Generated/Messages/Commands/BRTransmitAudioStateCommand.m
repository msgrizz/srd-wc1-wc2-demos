//
//  BRTransmitAudioStateCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTransmitAudioStateCommand.h"
#import "BRMessage_Private.h"


@implementation BRTransmitAudioStateCommand

#pragma mark - Public

+ (BRTransmitAudioStateCommand *)commandWithState:(BOOL)state
{
	BRTransmitAudioStateCommand *instance = [[BRTransmitAudioStateCommand alloc] init];
	instance.state = state;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TRANSMIT_AUDIO_STATE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"state", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTransmitAudioStateCommand %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
