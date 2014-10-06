//
//  BRSingleNVRAMConfigurationReadWithAddressEchoSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSingleNVRAMConfigurationReadWithAddressEchoSettingRequest.h"
#import "BRMessage_Private.h"




@implementation BRSingleNVRAMConfigurationReadWithAddressEchoSettingRequest

#pragma BRSettingRequest

+ (BRSingleNVRAMConfigurationReadWithAddressEchoSettingRequest *)requestWithConfigurationItemAddress:(uint32_t)configurationItemAddress
{
	BRSingleNVRAMConfigurationReadWithAddressEchoSettingRequest *instance = [[BRSingleNVRAMConfigurationReadWithAddressEchoSettingRequest alloc] init];
	instance.configurationItemAddress = configurationItemAddress;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRSingleNVRAMConfigurationReadWithAddressEchoSettingRequest %p> configurationItemAddress=0x%08X",
            self, self.configurationItemAddress];
}

@end
