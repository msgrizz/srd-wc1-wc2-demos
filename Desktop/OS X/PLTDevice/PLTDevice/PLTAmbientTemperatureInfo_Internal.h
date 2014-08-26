//
//  PLTSkinTemperatureInfo_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 6/20/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTSkinTemperatureInfo.h"


@interface PLTSkinTemperatureInfo ()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration
			  temperature:(uint16_t)temperature;

@end
