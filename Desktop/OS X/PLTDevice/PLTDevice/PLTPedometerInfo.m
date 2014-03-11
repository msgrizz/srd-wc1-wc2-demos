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

@property(nonatomic, readwrite)	NSUInteger	steps;

@end


@implementation PLTPedometerInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp steps:(NSUInteger)steps
{
	self = [super initWithRequestType:requestType timestamp:timestamp];
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
	return [NSString stringWithFormat:@"<PLTPedometerInfo: %p> {\n\trequestType: %u\n\ttimestamp: %@\n\tsteps: %u\n}",
			self, self.requestType, self.timestamp, self.steps];
}

@end
