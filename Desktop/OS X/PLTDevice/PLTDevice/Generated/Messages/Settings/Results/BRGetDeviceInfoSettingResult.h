//
//  BRGetDeviceInfoSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_GET_DEVICE_INFO_SETTING_RESULT 0xFF20



@interface BRGetDeviceInfoSettingResult : BRSettingResult

@property(nonatomic,readonly) NSData * majorHardwareVersion;
@property(nonatomic,readonly) NSData * minorHardwareVersion;
@property(nonatomic,readonly) NSData * majorFirmwareVersion;
@property(nonatomic,readonly) NSData * minorFirmwareVersion;
@property(nonatomic,readonly) NSData * supportedServices;


@end
