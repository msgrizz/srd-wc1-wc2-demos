//
//  PLTInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTInfo.h"
#import "PLTInfo_Internal.h"
#import "PLTDevice.h"


@interface PLTInfo()

//@property(readwrite, strong)	PLTDevice			*device;
//@property(nonatomic,strong,readwrite)	NSDate				*timestamp;
@property(nonatomic,strong,readwrite)	PLTCalibration		*calibration;

@end


@implementation PLTInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration
{
	self = [super init];
	self.requestType = requestType;
	self.timestamp = timestamp;
	self.calibration = calibration;
	return self;
}

#warning BANGLE
- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration serviceData:(NSData *)serviceData
{
	self = [super init];
	self.requestType = requestType;
	self.timestamp = timestamp;
	self.calibration = calibration;
	self.serviceData = serviceData;
	[self parseServiceData];
	return self;
}

- (void)parseServiceData
{
	// parse deckard "serviceData" and populate appropriate ivars
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTInfo: %p> requestType=%lu, timestamp=%@, calibration=%@",
			self, self.requestType, self.timestamp, self.calibration];
}

@end
