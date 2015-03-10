//
//  BRSetSystemToneVolumeCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetSystemToneVolumeCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetSystemToneVolumeCommand

#pragma mark - Public

+ (BRSetSystemToneVolumeCommand *)commandWithVolume:(uint8_t)volume
{
	BRSetSystemToneVolumeCommand *instance = [[BRSetSystemToneVolumeCommand alloc] init];
	instance.volume = volume;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_SYSTEM_TONE_VOLUME;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"volume", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetSystemToneVolumeCommand %p> volume=0x%02X",
            self, self.volume];
}

@end
