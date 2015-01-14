//
//  PLTAngularVelocityInfo_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 12/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTAngularVelocityInfo.h"


@interface PLTAngularVelocityInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration
		  angularVelocity:(PLTAngularVelocity)angularVelocity;

@end
