//
//  PLTOrientationTrackingCalibration.m
//  PLTDevice
//
//  Created by Davis, Morgan on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTOrientationTrackingCalibration.h"


@interface PLTOrientationTrackingCalibration()

- (id)initWithReferenceEulerAngles:(PLTEulerAngles)referenceEulerAngles;
- (id)initWithReferenceQuaternion:(PLTQuaternion)referenceQuaternion;

@end


@implementation PLTOrientationTrackingCalibration

@dynamic referenceEulerAngles;

- (PLTEulerAngles)referenceEulerAngles
{
	return EulerAnglesFromQuaternion(self.referenceQuaternion);
}

- (void)setReferenceEulerAngle:(PLTEulerAngles)anEulerAngles
{
	
}

#pragma mark - Public

+ (PLTOrientationTrackingCalibration *)calibrationWithReferenceEulerAngles:(PLTEulerAngles)referenceEulerAngles
{
	return [[PLTOrientationTrackingCalibration alloc] initWithReferenceEulerAngles:referenceEulerAngles];
}

+ (PLTOrientationTrackingCalibration *)calibrationWithReferenceQuaternion:(PLTQuaternion)referenceQuaternion
{
	return [[PLTOrientationTrackingCalibration alloc] initWithReferenceQuaternion:referenceQuaternion];
}

- (id)initWithReferenceEulerAngles:(PLTEulerAngles)referenceEulerAngles
{
	self = [super init];
	self.referenceEulerAngles = referenceEulerAngles;
	return self;
}

- (id)initWithReferenceQuaternion:(PLTQuaternion)referenceQuaternion
{
	self = [super init];
	self.referenceQuaternion = referenceQuaternion;
	return self;
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTOrientationTrackingCalibration: %p> {\n\treferenceEulerAngles: %@\n\treferenceQuaternion: %@\n}",
			self, NSStringFromEulerAngles(self.referenceEulerAngles), NSStringFromQuaternion(self.referenceQuaternion)];
}

@end
