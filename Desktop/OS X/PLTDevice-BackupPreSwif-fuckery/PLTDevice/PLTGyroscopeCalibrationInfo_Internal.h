//
//  PLTGyroscopeCalibrationInfo_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTGyroscopeCalibrationInfo.h"

@interface PLTGyroscopeCalibrationInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration
		calibrationStatus:(BOOL)isCalibrated;
@end
