//
//  PLTInfo_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTInfo.h"


@interface PLTInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration;

#warning BANGLE
- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration serviceData:(NSData *)serviceData;
- (void)parseServiceData;

@property(nonatomic,readwrite)			PLTInfoRequestType	requestType;
@property(nonatomic,strong,readwrite)	NSDate				*timestamp;
@property(nonatomic,strong,readwrite)	PLTCalibration		*calibration;
@property(nonatomic,strong)				NSData				*serviceData;

@end
