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

@property(nonatomic, readwrite)	NSUInteger		taps;
@property(nonatomic, readwrite)	PLTTapDirection	direction;

@end


@implementation PLTTapsInfo

#pragma mark - SDK Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp taps:(NSUInteger)taps direction:(PLTTapDirection)direction
{
	self = [super initWithRequestType:requestType timestamp:timestamp];
	self.taps = taps;
	self.direction = direction;
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTTapsInfo *)info
{
	return ((info.taps==self.taps) && (info.direction==self.direction));
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTTapsInfo: %p> {\n\trequestType: %u\n\ttimestamp: %@\n\ttaps: %u\n\tdirection: %u\n}",
			self, self.requestType, self.timestamp, self.taps, self.direction];
}

@end
