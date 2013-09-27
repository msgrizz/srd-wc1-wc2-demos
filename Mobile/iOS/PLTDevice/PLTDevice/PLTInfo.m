//
//  PLTInfo.m
//  PLTDevice
//
//  Created by Davis, Morgan on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTInfo.h"
#import "PLTInfo_Internal.h"
#import "PLTDevice.h"


@interface PLTInfo()

//@property(readwrite, strong)	PLTDevice			*device;
@property(nonatomic, readwrite, strong)	NSDate				*timestamp;

@end


@implementation PLTInfo

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp
{
	self = [super init];
	self.requestType = requestType;
	self.timestamp = timestamp;
	return self;
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTInfo: %p> {\n\trequestType: %u\n\ttimestamp: %@\n}",
			self, self.requestType, self.timestamp];
}

@end
