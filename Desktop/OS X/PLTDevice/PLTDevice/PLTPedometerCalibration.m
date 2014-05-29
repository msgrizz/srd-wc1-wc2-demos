//
//  PLTPedometerCalibration.m
//  PLTDevice
//
//  Created by Morgan Davis on 5/27/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTPedometerCalibration.h"


@implementation PLTPedometerCalibration

#pragma mark - Public

+ (PLTPedometerCalibration *)calibrationWithReset:(BOOL)reset
{
	return [[PLTPedometerCalibration alloc] initWithWithReset:reset];
}

- (id)initWithWithReset:(BOOL)reset
{
	self = [super init];
	self.reset = reset;
	return self;
}

@end
