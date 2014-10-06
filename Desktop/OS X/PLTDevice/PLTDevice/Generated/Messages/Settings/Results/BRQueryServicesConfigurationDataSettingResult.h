//
//  BRQueryServicesConfigurationDataSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_QUERY_SERVICES_CONFIGURATION_DATA_SETTING_RESULT 0xFF00



@interface BRQueryServicesConfigurationDataSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t serviceID;
@property(nonatomic,readonly) uint16_t characteristic;
@property(nonatomic,readonly) NSData * configurationData;


@end
