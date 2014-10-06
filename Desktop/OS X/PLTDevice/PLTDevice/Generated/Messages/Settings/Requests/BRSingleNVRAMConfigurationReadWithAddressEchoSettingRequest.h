//
//  BRSingleNVRAMConfigurationReadWithAddressEchoSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING_REQUEST 0x1019



@interface BRSingleNVRAMConfigurationReadWithAddressEchoSettingRequest : BRSettingRequest

+ (BRSingleNVRAMConfigurationReadWithAddressEchoSettingRequest *)requestWithConfigurationItemAddress:(uint32_t)configurationItemAddress;

@property(nonatomic,assign) uint32_t configurationItemAddress;


@end
