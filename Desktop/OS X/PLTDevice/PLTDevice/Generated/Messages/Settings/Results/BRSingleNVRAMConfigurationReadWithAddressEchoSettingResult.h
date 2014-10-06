//
//  BRSingleNVRAMConfigurationReadWithAddressEchoSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING_RESULT 0x1019



@interface BRSingleNVRAMConfigurationReadWithAddressEchoSettingResult : BRSettingResult

@property(nonatomic,readonly) uint32_t configurationItemAddress;
@property(nonatomic,readonly) NSData * nvramConfiguration;


@end
