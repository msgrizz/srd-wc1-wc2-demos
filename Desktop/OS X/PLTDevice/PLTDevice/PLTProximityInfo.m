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

@property(nonatomic, readwrite)	PLTProximity	pcProximity;
@property(nonatomic, readwrite)	PLTProximity	mobileProximity;

@end


@implementation PLTProximityInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp pcProximity:(PLTProximity)pcProximity mobileProximity:(PLTProximity)mobileProximity
{
	self = [super initWithRequestType:requestType timestamp:timestamp];
	self.pcProximity = pcProximity;
	self.mobileProximity = mobileProximity;
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTProximityInfo *)info
{
	return ((info.pcProximity==self.pcProximity) && (info.mobileProximity==self.mobileProximity));
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTProximityInfo: %p> {\n\trequestType: %u\n\ttimestamp: %@\n\tpcProximity: %u\n\tmobileProximity: %u\n}",
			self, self.requestType, self.timestamp, self.pcProximity, self.mobileProximity];
}

@end
