//
//  BRServiceCalibrationSettingRequest.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/11/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


@interface BRServiceCalibrationSettingRequest : BRSettingRequest

+ (BRServiceCalibrationSettingRequest *)requestWithServiceID:(uint16_t)serviceID;

@property(nonatomic,assign) uint16_t   serviceID;

@end
