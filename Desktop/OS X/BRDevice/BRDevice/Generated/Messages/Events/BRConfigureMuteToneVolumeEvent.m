//
//  BRConfigureMuteToneVolumeEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRConfigureMuteToneVolumeEvent.h"
#import "BRMessage_Private.h"


@interface BRConfigureMuteToneVolumeEvent ()

@property(nonatomic,assign,readwrite) uint8_t muteToneVolume;


@end


@implementation BRConfigureMuteToneVolumeEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_MUTE_TONE_VOLUME_EVENT;
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
    return [NSString stringWithFormat:@"<BRConfigureMuteToneVolumeEvent %p> muteToneVolume=0x%02X",
            self, self.muteToneVolume];
}

@end
