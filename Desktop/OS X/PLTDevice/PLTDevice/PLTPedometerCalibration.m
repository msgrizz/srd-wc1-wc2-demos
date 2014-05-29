//
//  PLTPedometerCalibration.m
//  PLTDevice
//
//  Created by Morgan Davis on 5/27/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTPedometerCalibration.h"


@interface PLTPedometerCalibration()

- (id)initWithWithReset:(BOOL)reset;

@end


@implementation PLTPedometerCalibration

#pragma mark - Public

+ (PLTPedometerCalibration *)calibrationWithReset:(BOOL)reset
{
	return [[PLTPedometerCalibration alloc] initWithWithReset:reset];
}

#pragma mark - Private

- (id)initWithWithReset:(BOOL)reset
{
	self = [super init];
	self.reset = reset;
	return self;
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTPedometerCalibration: %p> reset=%@",
			self, (self.reset?@"YES":@"NO")];
}

@end
