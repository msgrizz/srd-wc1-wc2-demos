//
//  BRSingleNVRAMConfigurationReadWithAddressEchoSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSingleNVRAMConfigurationReadWithAddressEchoSettingResult.h"
#import "BRMessage_Private.h"


@interface BRSingleNVRAMConfigurationReadWithAddressEchoSettingResult ()

@property(nonatomic,assign,readwrite) uint32_t configurationItemAddress;
@property(nonatomic,strong,readwrite) NSData * nvramConfiguration;


@end


@implementation BRSingleNVRAMConfigurationReadWithAddressEchoSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"configurationItemAddress", @"type": @(BRPayloadItemTypeUnsignedLong)},
			@{@"name": @"nvramConfiguration", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSingleNVRAMConfigurationReadWithAddressEchoSettingResult %p> configurationItemAddress=0x%08X, nvramConfiguration=%@",
            self, self.configurationItemAddress, self.nvramConfiguration];
}

@end
