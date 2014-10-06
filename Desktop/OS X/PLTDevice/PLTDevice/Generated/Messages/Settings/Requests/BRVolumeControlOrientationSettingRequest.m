//
//  BRVolumeControlOrientationSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRVolumeControlOrientationSettingRequest.h"
#import "BRMessage_Private.h"




@implementation BRVolumeControlOrientationSettingRequest

#pragma BRSettingRequest

+ (BRVolumeControlOrientationSettingRequest *)request
{
	BRVolumeControlOrientationSettingRequest *instance = [[BRVolumeControlOrientationSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOLUME_CONTROL_ORIENTATION_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRVolumeControlOrientationSettingRequest %p>",
            self];
}

@end
