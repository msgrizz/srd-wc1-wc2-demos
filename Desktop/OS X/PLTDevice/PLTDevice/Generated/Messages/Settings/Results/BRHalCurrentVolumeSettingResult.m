//
//  BRHalCurrentVolumeSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHalCurrentVolumeSettingResult.h"
#import "BRMessage_Private.h"




@interface BRHalCurrentVolumeSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t scenario;
@property(nonatomic,strong,readwrite) NSData * volumes;


@end


@implementation BRHalCurrentVolumeSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_CURRENT_VOLUME_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"scenario", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"volumes", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHalCurrentVolumeSettingResult %p> scenario=0x%04X, volumes=%@",
            self, self.scenario, self.volumes];
}

@end
