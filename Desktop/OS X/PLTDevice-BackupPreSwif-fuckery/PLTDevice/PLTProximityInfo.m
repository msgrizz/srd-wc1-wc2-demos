//
//  PLTProximityInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTProximityInfo.h"
#import "PLTInfo_Internal.h"


NSString *NSStringFromProximity(PLTProximity proximity)
{
	switch (proximity) {
		case PLTProximityFar:
			return @"far";
		case PLTProximityNear:
			return @"near";
		case PLTProximityUnknown:
			return @"unknown";
	}
	return nil;
}


@interface PLTProximityInfo()

@property(nonatomic,readwrite)	PLTProximity	localProximity;
@property(nonatomic,readwrite)	PLTProximity	remoteProximity;

@end


@implementation PLTProximityInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration
		   localProximity:(PLTProximity)localProximity remoteProximity:(PLTProximity)remoteProximity
{
	self = [super initWithRequestType:requestType timestamp:timestamp calibration:calibration];
	self.localProximity = localProximity;
	self.remoteProximity = remoteProximity;
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTProximityInfo *)info
{
	return ((info.localProximity==self.localProximity) && (info.remoteProximity==self.remoteProximity));
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTProximityInfo: %p> requestType=%lu, timestamp=%@, localProximity=%lu, remoteProximity=%lu",
			self, self.requestType, self.timestamp, self.localProximity, self.remoteProximity];
}

@end
