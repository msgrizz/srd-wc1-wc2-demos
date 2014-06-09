//
//  PLTWearingStateInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTWearingStateInfo.h"
#import "PLTInfo_Internal.h"


@interface PLTWearingStateInfo()

@property(nonatomic,readwrite)	BOOL	isBeingWorn;

@end


@implementation PLTWearingStateInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration
			 wearingState:(BOOL)isBeingWorn
{
	self = [super initWithRequestType:requestType timestamp:timestamp calibration:calibration];
	self.isBeingWorn = isBeingWorn;
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTWearingStateInfo *)info
{
	return (info.isBeingWorn == self.isBeingWorn);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTWearingStateInfo: %p> requestType=%u, timestamp=%@, isBeingWorn=%@",
			self, self.requestType, self.timestamp, (self.isBeingWorn ? @"YES" : @"NO")];
}

@end
