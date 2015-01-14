//
//  BRSetSpeakerVolumeCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetSpeakerVolumeCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetSpeakerVolumeCommand

#pragma mark - Public

+ (BRSetSpeakerVolumeCommand *)commandWithAction:(uint8_t)action volume:(int16_t)volume
{
	BRSetSpeakerVolumeCommand *instance = [[BRSetSpeakerVolumeCommand alloc] init];
	instance.action = action;
	instance.volume = volume;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_SPEAKER_VOLUME;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"action", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"volume", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetSpeakerVolumeCommand %p> action=0x%02X, volume=0x%04X",
            self, self.action, self.volume];
}

@end
