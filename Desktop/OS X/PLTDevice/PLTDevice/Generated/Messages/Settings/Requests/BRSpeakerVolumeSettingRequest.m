//
//  BRSpeakerVolumeSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSpeakerVolumeSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRSpeakerVolumeSettingRequest

#pragma BRSettingRequest

+ (BRSpeakerVolumeSettingRequest *)request
{
	BRSpeakerVolumeSettingRequest *instance = [[BRSpeakerVolumeSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SPEAKER_VOLUME_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[

			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSpeakerVolumeSettingRequest %p>",
            self];
}

@end
