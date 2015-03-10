//
//  BRQueryApplicationConfigurationDataSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_QUERY_APPLICATION_CONFIGURATION_DATA_SETTING_REQUEST 0xFF02



@interface BRQueryApplicationConfigurationDataSettingRequest : BRSettingRequest

+ (BRQueryApplicationConfigurationDataSettingRequest *)requestWithFeatureID:(uint16_t)featureID characteristic:(uint16_t)characteristic;

@property(nonatomic,assign) uint16_t featureID;
@property(nonatomic,assign) uint16_t characteristic;


@end
