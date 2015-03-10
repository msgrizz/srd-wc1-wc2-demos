//
//  BRSingleNVRAMConfigurationReadSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSingleNVRAMConfigurationReadSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRSingleNVRAMConfigurationReadSettingRequest

#pragma BRSettingRequest

+ (BRSingleNVRAMConfigurationReadSettingRequest *)requestWithConfigurationItemAddress:(uint32_t)configurationItemAddress
{
	BRSingleNVRAMConfigurationReadSettingRequest *instance = [[BRSingleNVRAMConfigurationReadSettingRequest alloc] init];
	instance.configurationItemAddress = configurationItemAddress;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SINGLE_NVRAM_CONFIGURATION_READ_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"configurationItemAddress", @"type": @(BRPayloadItemTypeUnsignedLong)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSingleNVRAMConfigurationReadSettingRequest %p> configurationItemAddress=0x%08X",
            self, self.configurationItemAddress];
}

@end
