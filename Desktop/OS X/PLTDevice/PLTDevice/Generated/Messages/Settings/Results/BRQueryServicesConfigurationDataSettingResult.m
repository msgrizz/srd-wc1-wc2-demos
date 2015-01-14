//
//  BRQueryServicesConfigurationDataSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRQueryServicesConfigurationDataSettingResult.h"
#import "BRMessage_Private.h"


@interface BRQueryServicesConfigurationDataSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t serviceID;
@property(nonatomic,assign,readwrite) uint16_t characteristic;
@property(nonatomic,strong,readwrite) NSData * configurationData;


@end


@implementation BRQueryServicesConfigurationDataSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_QUERY_SERVICES_CONFIGURATION_DATA_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serviceID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"configurationData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRQueryServicesConfigurationDataSettingResult %p> serviceID=0x%04X, characteristic=0x%04X, configurationData=%@",
            self, self.serviceID, self.characteristic, self.configurationData];
}

@end
