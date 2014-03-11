//
//  PLTGyroscopeCalibrationInfo_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTGyroscopeCalibrationInfo.h"

@interface PLTGyroscopeCalibrationInfo()

- (id)initWithCalibrationStatus:(BOOL)isCalibrated;- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibrationStatus:(BOOL)isCalibrated;
@end
