//
//  PLTMagnetometerCalibrationInfo
//  PLTDevice
//
//  Created by Davis, Morgan on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTMagnetometerCalibrationInfo.h"
#import "PLTInfo_Internal.h"


@interface PLTMagnetometerCalibrationInfo()

@property(nonatomic, readwrite)	BOOL	isCalibrated;

@end


@implementation PLTMagnetometerCalibrationInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibrationStatus:(BOOL)isCalibrated
{
	self = [super initWithRequestType:requestType timestamp:timestamp];
	self.isCalibrated = isCalibrated;
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTMagnetometerCalibrationInfo *)info
{
	return (info.isCalibrated==self.isCalibrated);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTMagnetometerCalibrationInfo: %p> {\n\trequestType: %u\n\ttimestamp: %@\n\tisCalibrated: %@\n}",
			self, self.requestType, self.timestamp, (self.isCalibrated ? @"YES" : @"NO")];
}

@end
