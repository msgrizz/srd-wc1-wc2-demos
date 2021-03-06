//
//  PLTTapsInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTTapsInfo.h"
#import "PLTInfo_Internal.h"


NSString *NSStringFromTapDirection(PLTTapDirection direction)
{
	switch (direction) {
		case PLTTapDirectionXUp:
			return @"x up";
		case PLTTapDirectionXDown:
			return @"x down";
		case PLTTapDirectionYUp:
			return @"y up";
		case PLTTapDirectionYDown:
			return @"y down";
		case PLTTapDirectionZUp:
			return @"z up";
		case PLTTapDirectionZDown:
			return @"z down";
	}
	return nil;
}


@interface PLTTapsInfo()

@property(nonatomic,readwrite)	PLTTapDirection	direction;
@property(nonatomic,readwrite)	NSUInteger		count;

@end


@implementation PLTTapsInfo

#pragma mark - SDK Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp calibration:(PLTCalibration *)calibration
				direction:(PLTTapDirection)direction count:(NSUInteger)count
{
	self = [super initWithRequestType:requestType timestamp:timestamp calibration:calibration];
	self.direction = direction;
	self.count = count;
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTTapsInfo *)info
{
	return ((info.direction==self.direction) && (info.count==self.count));
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTTapsInfo: %p> requestType=%lu, timestamp=%@, direction=%u, count=%lu",
			self, self.requestType, self.timestamp, self.direction, (unsigned long)self.count];
}

@end
