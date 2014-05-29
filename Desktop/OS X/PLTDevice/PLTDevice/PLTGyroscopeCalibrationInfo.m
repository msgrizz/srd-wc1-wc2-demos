//
//  PLTGyroscopeCalibrationInfo
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTGyroscopeCalibrationInfo.h"
#import "PLTInfo_Internal.h"


@interface PLTGyroscopeCalibrationInfo()

@property(nonatomic,readwrite)	BOOL	isCalibrated;

@end


@implementation PLTGyroscopeCalibrationInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration
		calibrationStatus:(BOOL)isCalibrated
{
	self = [super initWithRequestType:requestType timestamp:timestamp calibration:calibration];
	self.isCalibrated = isCalibrated;
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTGyroscopeCalibrationInfo *)info
{
	return (info.isCalibrated==self.isCalibrated);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTGyroscopeCalibrationInfo: %p> {\n\trequestType: %u\n\ttimestamp: %@\n\tisCalibrated: %@\n}",
			self, self.requestType, self.timestamp, (self.isCalibrated ? @"YES" : @"NO")];
}

@end
