//
//  PLTWearingStateInfo.m
//  PLTDevice
//
//  Created by Davis, Morgan on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTWearingStateInfo.h"
#import "PLTInfo_Internal.h"


@interface PLTWearingStateInfo()

@property(nonatomic, readwrite)	BOOL	isBeingWorn;

@end


@implementation PLTWearingStateInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp wearingState:(BOOL)isBeingWorn
{
	self = [super initWithRequestType:requestType timestamp:timestamp];
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
	return [NSString stringWithFormat:@"<PLTWearingStateInfo: %p> {\n\trequestType: %u\n\ttimestamp: %@\n\tisBeingWorn: %@\n}",
			self, self.requestType, self.timestamp, (self.isBeingWorn ? @"YES" : @"NO")];
}

@end
