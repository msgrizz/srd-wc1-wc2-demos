//
//  BRHalCurrentVolumeSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHalCurrentVolumeSettingRequest.h"
#import "BRMessage_Private.h"




@implementation BRHalCurrentVolumeSettingRequest

#pragma BRSettingRequest

+ (BRHalCurrentVolumeSettingRequest *)requestWithScenario:(uint16_t)scenario volumes:(NSData *)volumes
{
	BRHalCurrentVolumeSettingRequest *instance = [[BRHalCurrentVolumeSettingRequest alloc] init];
	instance.scenario = scenario;
	instance.volumes = volumes;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_CURRENT_VOLUME_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRHalCurrentVolumeSettingRequest %p> scenario=0x%04X, volumes=%@",
            self, self.scenario, self.volumes];
}

@end
