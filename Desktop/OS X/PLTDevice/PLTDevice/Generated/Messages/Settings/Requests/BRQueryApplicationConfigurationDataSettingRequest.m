//
//  BRQueryApplicationConfigurationDataSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRQueryApplicationConfigurationDataSettingRequest.h"
#import "BRMessage_Private.h"




@implementation BRQueryApplicationConfigurationDataSettingRequest

#pragma BRSettingRequest

+ (BRQueryApplicationConfigurationDataSettingRequest *)requestWithFeatureID:(uint16_t)featureID characteristic:(uint16_t)characteristic
{
	BRQueryApplicationConfigurationDataSettingRequest *instance = [[BRQueryApplicationConfigurationDataSettingRequest alloc] init];
	instance.featureID = featureID;
	instance.characteristic = characteristic;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_QUERY_APPLICATION_CONFIGURATION_DATA_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"featureID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRQueryApplicationConfigurationDataSettingRequest %p> featureID=0x%04X, characteristic=0x%04X",
            self, self.featureID, self.characteristic];
}

@end
