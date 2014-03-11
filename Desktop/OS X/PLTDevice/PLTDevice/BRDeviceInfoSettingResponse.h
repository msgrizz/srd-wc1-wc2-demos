//
//  BRDeviceInfoSettingResponse.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"


@interface BRDeviceInfoSettingResponse : BRSettingResponse

@property(nonatomic,readonly) NSArray   *majorHardwareVersions;
@property(nonatomic,readonly) NSArray   *minorHardwareVersions;
@property(nonatomic,readonly) NSArray   *majorSoftwareVersions;
@property(nonatomic,readonly) NSArray   *minorSoftwareVersions;
@property(nonatomic,readonly) NSArray   *supportedServices;

@end
