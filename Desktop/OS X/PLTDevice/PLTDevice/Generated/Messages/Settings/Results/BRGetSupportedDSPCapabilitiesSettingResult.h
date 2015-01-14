//
//  BRGetSupportedDSPCapabilitiesSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_GET_SUPPORTED_DSP_CAPABILITIES_SETTING_RESULT 0x0F40



@interface BRGetSupportedDSPCapabilitiesSettingResult : BRSettingResult

@property(nonatomic,readonly) NSData * supportedAndActive;


@end
