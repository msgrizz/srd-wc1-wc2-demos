//
//  PLTAmbientHumidityInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 6/20/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTAmbientHumidityInfo.h"
#import "PLTInfo_Internal.h"


@interface PLTAmbientHumidityInfo ()

@property(nonatomic,assign,readwrite)	float	humidity;

@end


@implementation PLTAmbientHumidityInfo

#pragma mark - SDK Internal

- (void)parseServiceData
{
	uint16_t humidity;
	[[self.serviceData subdataWithRange:NSMakeRange(0, sizeof(uint16_t))] getBytes:&humidity length:sizeof(uint16_t)];
	humidity = ntohs(humidity);
	self.humidity = ((float)humidity) / 100.0;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTAmbientHumidityInfo *)info
{
	return fabs(self.humidity - info.humidity) < 0.00001;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTAmbientHumidityInfo: %p> requestType=%lu, timestamp=%@, humidity=%.2f",
			self, self.requestType, self.timestamp, self.humidity];
}

@end
