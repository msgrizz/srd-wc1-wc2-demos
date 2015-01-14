//
//  PLTMagnetismInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 12/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTMagnetismInfo.h"
#import "PLTInfo_Internal.h"


NSString *NSStringFromMagnetism(PLTMagnetism magnetism)
{
	return [NSString stringWithFormat:@"{ %f, %f, %f }", magnetism.x, magnetism.y, magnetism.z];
}


@interface PLTMagnetismInfo()

@property(nonatomic,assign,readwrite)	PLTMagnetism	magnetism;

@end


@implementation PLTMagnetismInfo

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
	struct Q16 {
		int16_t m;
		uint16_t n;
	};
	struct RawVec3 {
		struct Q16 x;
		struct Q16 y;
		struct Q16 z;
	};
	float d = exp2f(16);
	struct RawVec3 rv3;
	
	[self.serviceData getBytes:&rv3 length:sizeof(rv3)];
	
	rv3.x.m = ntohs(rv3.x.m);
	rv3.x.n = ntohs(rv3.x.n);
	rv3.y.m = ntohs(rv3.y.m);
	rv3.y.n = ntohs(rv3.y.n);
	rv3.z.m = ntohs(rv3.z.m);
	rv3.z.n = ntohs(rv3.z.n);
	
	self.magnetism = (PLTMagnetism) {
		(float)rv3.x.m + ((float)rv3.x.n)/d,
		(float)rv3.y.m + ((float)rv3.y.n)/d,
		(float)rv3.z.m + ((float)rv3.z.n)/d };
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTMagnetismInfo: %p> requestType=%lu, timestamp=%@, calibration=%@, magnetism=%@",
			self, self.requestType, self.timestamp, self.calibration, NSStringFromMagnetism(self.magnetism)];
}

@end
