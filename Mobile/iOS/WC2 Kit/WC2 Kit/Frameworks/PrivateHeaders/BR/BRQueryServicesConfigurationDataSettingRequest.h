//
//  BRQueryServicesConfigurationDataSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_QUERY_SERVICES_CONFIGURATION_DATA_SETTING_REQUEST 0xFF00



@interface BRQueryServicesConfigurationDataSettingRequest : BRSettingRequest

+ (BRQueryServicesConfigurationDataSettingRequest *)requestWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic;

@property(nonatomic,assign) uint16_t serviceID;
@property(nonatomic,assign) uint16_t characteristic;


@end
