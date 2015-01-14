//
//  BRVolumeControlOrientationSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRVolumeControlOrientationSettingResult.h"
#import "BRMessage_Private.h"


@interface BRVolumeControlOrientationSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t orientation;


@end


@implementation BRVolumeControlOrientationSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOLUME_CONTROL_ORIENTATION_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"orientation", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRVolumeControlOrientationSettingResult %p> orientation=0x%02X",
            self, self.orientation];
}

@end
