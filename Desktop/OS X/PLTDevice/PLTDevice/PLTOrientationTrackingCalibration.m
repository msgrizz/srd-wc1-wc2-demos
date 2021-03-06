//
//  PLTOrientationTrackingCalibration.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTOrientationTrackingCalibration.h"
#import "PLTOrientationTrackingInfo_Internal.h"


@interface PLTOrientationTrackingCalibration()

- (id)initWithReferenceOrientationTrackingInfo:(PLTOrientationTrackingInfo *)info;
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
    self.referenceQuaternion = QuaternionFromEulerAngles(anEulerAngles);
}

#pragma mark - Public

+ (PLTOrientationTrackingCalibration *)calibrationWithReferenceOrientationTrackingInfo:(PLTOrientationTrackingInfo *)info
{
	return [[PLTOrientationTrackingCalibration alloc] initWithReferenceOrientationTrackingInfo:info];
}

+ (PLTOrientationTrackingCalibration *)calibrationWithReferenceEulerAngles:(PLTEulerAngles)referenceEulerAngles
{
	return [[PLTOrientationTrackingCalibration alloc] initWithReferenceEulerAngles:referenceEulerAngles];
}

+ (PLTOrientationTrackingCalibration *)calibrationWithReferenceQuaternion:(PLTQuaternion)referenceQuaternion
{
	return [[PLTOrientationTrackingCalibration alloc] initWithReferenceQuaternion:referenceQuaternion];
}

#pragma mark - Private

- (id)initWithReferenceOrientationTrackingInfo:(PLTOrientationTrackingInfo *)info
{
	self = [super init];
	self.referenceQuaternion = info.quaternion;
	return self;
}

- (id)initWithReferenceEulerAngles:(PLTEulerAngles)referenceEulerAngles
{
	self = [super init];
	self.referenceQuaternion = QuaternionFromEulerAngles(referenceEulerAngles);
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
	return [NSString stringWithFormat:@"<PLTOrientationTrackingCalibration: %p> referenceEulerAngles=%@, referenceQuaternion=%@",
			self, NSStringFromEulerAngles(self.referenceEulerAngles), NSStringFromQuaternion(self.referenceQuaternion)];
}

@end
