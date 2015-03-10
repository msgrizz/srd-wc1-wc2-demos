//
//  BRSingleNVRAMConfigurationReadSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_SINGLE_NVRAM_CONFIGURATION_READ_SETTING_RESULT 0x1009



@interface BRSingleNVRAMConfigurationReadSettingResult : BRSettingResult

@property(nonatomic,readonly) NSData * nvramConfiguration;


@end
