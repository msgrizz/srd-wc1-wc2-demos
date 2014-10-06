//
//  BRQueryApplicationConfigurationDataSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_QUERY_APPLICATION_CONFIGURATION_DATA_SETTING_RESULT 0xFF02



@interface BRQueryApplicationConfigurationDataSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t featureID;
@property(nonatomic,readonly) uint16_t characteristic;
@property(nonatomic,readonly) NSData * configurationData;


@end
