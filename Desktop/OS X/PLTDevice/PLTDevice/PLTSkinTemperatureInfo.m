//
//  PLTSkinTemperatureInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 6/20/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTSkinTemperatureInfo.h"
#import "PLTInfo_Internal.h"


float PLTFahrenheitFromCelsius(float c)
{
	return c * (9.0/5.0) + 32.0;
}


@interface PLTSkinTemperatureInfo ()

@property(nonatomic,assign,readwrite)	float	temperature;

@end


@implementation PLTSkinTemperatureInfo

#pragma mark - SDK Internal

- (void)parseServiceData
{
	uint16_t temp;
	[[self.serviceData subdataWithRange:NSMakeRange(0, sizeof(uint16_t))] getBytes:&temp length:sizeof(uint16_t)];
	temp = ntohs(temp);
	self.temperature = ((float)temp) / 100.0;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTSkinTemperatureInfo *)info
{
	return fabs(self.temperature - info.temperature) < 0.00001;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTSkinTemperatureInfo: %p> requestType=%lu, timestamp=%@, temperature=%.2f",
			self, self.requestType, self.timestamp, self.temperature];
}

@end
