//
//  BRGetMuteToneVolumeSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRGetMuteToneVolumeSettingResult.h"
#import "BRMessage_Private.h"


@interface BRGetMuteToneVolumeSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t muteToneVolume;


@end


@implementation BRGetMuteToneVolumeSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_MUTE_TONE_VOLUME_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRGetMuteToneVolumeSettingResult %p> muteToneVolume=0x%02X",
            self, self.muteToneVolume];
}

@end
