//
//  PLTPedometerInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTPedometerInfo.h"
#import "PLTInfo_Internal.h"


@interface PLTPedometerInfo()

@property(nonatomic,readwrite)	NSUInteger	steps;

@end


@implementation PLTPedometerInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration
					steps:(NSUInteger)steps
{
	self = [super initWithRequestType:requestType timestamp:timestamp calibration:calibration];
	self.steps = steps;
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTPedometerInfo *)info
{
	return (info.steps==self.steps);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTPedometerInfo: %p> requestType=%lu, timestamp=%@, steps=%lu",
			self, self.requestType, self.timestamp, (unsigned long)self.steps];
}

@end
