//
//  PLTTapsInfo_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTTapsInfo.h"


@interface PLTTapsInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp  calibration:(PLTCalibration *)calibration
				direction:(PLTTapDirection)direction count:(NSUInteger)count; 

@end
