//
//  BRGetMuteToneVolumeSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGetMuteToneVolumeSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRGetMuteToneVolumeSettingRequest

#pragma BRSettingRequest

+ (BRGetMuteToneVolumeSettingRequest *)request
{
	BRGetMuteToneVolumeSettingRequest *instance = [[BRGetMuteToneVolumeSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_MUTE_TONE_VOLUME_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRGetMuteToneVolumeSettingRequest %p>",
            self];
}

@end
