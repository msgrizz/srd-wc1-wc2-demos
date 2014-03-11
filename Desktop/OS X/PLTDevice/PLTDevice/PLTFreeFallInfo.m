//
//  PLTFreeFallInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTFreeFallInfo.h"
#import "PLTInfo_Internal.h"


@interface PLTFreeFallInfo()

@property(nonatomic, readwrite)	BOOL	isInFreeFall;

@end


@implementation PLTFreeFallInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp freeFall:(BOOL)isInFreeFall
{
	self = [super initWithRequestType:requestType timestamp:timestamp];
	self.isInFreeFall = isInFreeFall;
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTFreeFallInfo *)info
{
	return (info.isInFreeFall==self.isInFreeFall);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTFreeFallInfo: %p> {\n\trequestType: %u\n\ttimestamp: %@\n\tisInFreeFall: %@\n}",
			self, self.requestType, self.timestamp, (self.isInFreeFall ? @"YES" : @"NO")];
}

@end
