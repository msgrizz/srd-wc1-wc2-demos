//
//  BRSpeakerVolumeSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSpeakerVolumeSettingResult.h"
#import "BRMessage_Private.h"




@interface BRSpeakerVolumeSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t volumeValueType;
@property(nonatomic,assign,readwrite) int16_t volume;


@end


@implementation BRSpeakerVolumeSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SPEAKER_VOLUME_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"volumeValueType", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"volume", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSpeakerVolumeSettingResult %p> volumeValueType=0x%02X, volume=0x%04X",
            self, self.volumeValueType, self.volume];
}

@end
