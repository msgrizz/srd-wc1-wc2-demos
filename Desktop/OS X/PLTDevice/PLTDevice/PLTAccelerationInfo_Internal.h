//
//  PLTAccelerationInfo_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 12/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTAccelerationInfo.h"


@interface PLTAccelerationInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration
			 acceleration:(PLTAcceleration)acceleration;

@end
