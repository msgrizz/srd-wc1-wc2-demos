//
//  BRSingleNVRAMConfigurationReadWithAddressEchoSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING_RESULT 0x1019



@interface BRSingleNVRAMConfigurationReadWithAddressEchoSettingResult : BRSettingResult

@property(nonatomic,readonly) uint32_t configurationItemAddress;
@property(nonatomic,readonly) NSData * nvramConfiguration;


@end
