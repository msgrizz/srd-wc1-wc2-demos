//
//  PLTAmbientPressureInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 6/20/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTAmbientPressureInfo.h"
#import "PLTInfo_Internal.h"


@interface PLTAmbientPressureInfo ()

@property(nonatomic,assign,readwrite)	float	pressure;

@end


@implementation PLTAmbientPressureInfo

#pragma mark - SDK Internal

- (void)parseServiceData
{
	uint16_t pressure;
	[[self.serviceData subdataWithRange:NSMakeRange(0, sizeof(uint16_t))] getBytes:&pressure length:sizeof(uint16_t)];
	pressure = ntohs(pressure);
	self.pressure = ((float)pressure) / 100.0;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTAmbientPressureInfo *)info
{
	float absPressure = fabsf(info.pressure - self.pressure);
	return (absPressure<.01);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTAmbientPressureInfo: %p> requestType=%lu, timestamp=%@, pressure=%.2f",
			self, self.requestType, self.timestamp, self.pressure];
}

@end
