//
//  BRSignalStrengthConfigurationSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_SIGNAL_STRENGTH_CONFIGURATION_SETTING_REQUEST 0x0806



@interface BRSignalStrengthConfigurationSettingRequest : BRSettingRequest

+ (BRSignalStrengthConfigurationSettingRequest *)requestWithConnectionId:(uint8_t)connectionId;

@property(nonatomic,assign) uint8_t connectionId;


@end
