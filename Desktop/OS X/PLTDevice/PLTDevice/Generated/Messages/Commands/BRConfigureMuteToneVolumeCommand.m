//
//  BRConfigureMuteToneVolumeCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureMuteToneVolumeCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureMuteToneVolumeCommand

#pragma mark - Public

+ (BRConfigureMuteToneVolumeCommand *)commandWithMuteToneVolume:(uint8_t)muteToneVolume
{
	BRConfigureMuteToneVolumeCommand *instance = [[BRConfigureMuteToneVolumeCommand alloc] init];
	instance.muteToneVolume = muteToneVolume;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_MUTE_TONE_VOLUME;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"muteToneVolume", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureMuteToneVolumeCommand %p> muteToneVolume=0x%02X",
            self, self.muteToneVolume];
}

@end
