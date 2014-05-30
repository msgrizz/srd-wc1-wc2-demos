//
//  PLTOrientationTrackingInfo_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTOrientationTrackingInfo.h"


@class PLTOrientationTrackingCalibration;

@interface PLTOrientationTrackingInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTOrientationTrackingCalibration *)calibration
			   quaternion:(PLTQuaternion)quaternion;

@property(nonatomic,assign)	PLTQuaternion	uncalibratedQuaternion;
@property(nonatomic,assign)	PLTEulerAngles	uncalibratedEulerAngles;

@end
