//
//  BRSingleNVRAMConfigurationReadSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_SINGLE_NVRAM_CONFIGURATION_READ_SETTING_REQUEST 0x1009



@interface BRSingleNVRAMConfigurationReadSettingRequest : BRSettingRequest

+ (BRSingleNVRAMConfigurationReadSettingRequest *)requestWithConfigurationItemAddress:(uint32_t)configurationItemAddress;

@property(nonatomic,assign) uint32_t configurationItemAddress;


@end
