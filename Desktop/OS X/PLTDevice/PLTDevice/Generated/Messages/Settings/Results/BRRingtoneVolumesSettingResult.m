//
//  BRRingtoneVolumesSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRingtoneVolumesSettingResult.h"
#import "BRMessage_Private.h"




@interface BRRingtoneVolumesSettingResult ()

@property(nonatomic,strong,readwrite) NSData * volumes;


@end


@implementation BRRingtoneVolumesSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RINGTONE_VOLUMES_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"volumes", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRRingtoneVolumesSettingResult %p> volumes=%@",
            self, self.volumes];
}

@end
