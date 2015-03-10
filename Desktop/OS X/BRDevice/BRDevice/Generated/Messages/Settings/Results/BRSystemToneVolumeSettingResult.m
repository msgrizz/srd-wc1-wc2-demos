//
//  BRSystemToneVolumeSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSystemToneVolumeSettingResult.h"
#import "BRMessage_Private.h"


@interface BRSystemToneVolumeSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t volume;


@end


@implementation BRSystemToneVolumeSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SYSTEM_TONE_VOLUME_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRSystemToneVolumeSettingResult %p> volume=0x%02X",
            self, self.volume];
}

@end
