//
//  PLTHeadingInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 12/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTHeadingInfo.h"
#import "PLTInfo_Internal.h"


@interface PLTHeadingInfo()

@property(nonatomic,assign,readwrite)	PLTHeading	heading;

@end


@implementation PLTHeadingInfo

#pragma mark - API Internal

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
	float d = exp2f(16);
	struct mn {
		uint16_t m;
		uint16_t n;
	};
	struct mn rh;
	[self.serviceData getBytes:&rh length:sizeof(rh)];
	rh.m = ntohs(rh.m);
	rh.n = ntohs(rh.n);
	self.heading = (double)rh.m + ((double)rh.n)/d;
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTHeadingInfo: %p> requestType=%lu, timestamp=%@, calibration=%@, heading=%f",
			self, self.requestType, self.timestamp, self.calibration, self.heading];
}

@end
