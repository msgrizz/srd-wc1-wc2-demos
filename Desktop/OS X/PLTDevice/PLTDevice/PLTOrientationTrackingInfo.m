//
//  PLTOrientationTrackingInfo.m
//  PLTDevice
//
//  Created by Morgan Davis on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTOrientationTrackingInfo.h"
#import "PLTInfo_Internal.h"
#import "PLTOrientationTrackingCalibration.h"


double d2r(double d)
{
	return d * (M_PI/180.0);
}

double r2d(double d)
{
	return d * (180.0/M_PI);
}

PLTEulerAngles EulerAnglesFromQuaternion(PLTQuaternion q)
{
	double q0 = q.w;
	double q1 = q.x;
	double q2 = q.y;
	double q3 = q.z;
	
	double m22 = 2*pow(q0,2) + 2*pow(q2,2) - 1;
	double m21 = 2*q1*q2 - 2*q0*q3;
	double m13 = 2*q1*q3 - 2*q0*q2;
	double m23 = 2*q2*q3 + 2*q0*q1;
	double m33 = 2*pow(q0,2) + 2*pow(q3,2) - 1;
	
	double psi = -r2d(atan2(m21,m22));
	double theta = r2d(asin(m23));
	double phi = -r2d(atan2(m13, m33));
	
    return (PLTEulerAngles){ psi, theta, phi };
}

PLTQuaternion QuaternionFromEulerAngles(PLTEulerAngles eulerAngles)
{
    double psi = d2r(eulerAngles.x);
	double theta = d2r(eulerAngles.y);
	double phi = d2r(eulerAngles.z);
	
	double q0=cos(psi/2.0)*cos(theta/2.0)*cos(phi/2.0)-sin(psi/2.0)*sin(theta/2.0)*sin(phi/2.0);
	double q1=cos(psi/2.0)*sin(theta/2.0)*cos(phi/2.0)-sin(psi/2.0)*cos(theta/2.0)*sin(phi/2.0);
	double q2=cos(psi/2.0)*cos(theta/2.0)*sin(phi/2.0)+sin(psi/2.0)*sin(theta/2.0)*cos(phi/2.0);
	double q3=sin(psi/2.0)*cos(theta/2.0)*cos(phi/2.0)+cos(psi/2.0)*sin(theta/2.0)*sin(phi/2.0);
	
	return (PLTQuaternion){ q0, q1, q2, q3 };
}

PLTQuaternion MultipliedQuaternions(PLTQuaternion q, PLTQuaternion p)
{
	double *mulQuat = malloc(sizeof(double)*4);
    memset(mulQuat, 0, sizeof(double)*4);
    
    double quatmat[4][4] =
    {   { p.w, -p.x, -p.y, -p.z },
        { p.x, p.w, -p.z, p.y },
        { p.y, p.z, p.w, -p.x },
        { p.z, -p.y, p.x, p.w },
    };
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
			double *qq = (double *)&q;
            mulQuat[i] += quatmat[i][j] * qq[j];
        }
    }
    
	return (PLTQuaternion){ mulQuat[0], mulQuat[1], mulQuat[2], mulQuat[3] };
}

PLTQuaternion InverseQuaternion(PLTQuaternion q)
{
	return (PLTQuaternion){ q.w, -q.x, -q.y, -q.z };
}

BOOL EulerAnglesAreEqual( PLTEulerAngles a, PLTEulerAngles b)
{
	return ((a.x==b.x) && (a.y==b.y) && (a.z==b.z));
}

NSString *NSStringFromEulerAngles(PLTEulerAngles angles)
{
	return [NSString stringWithFormat:@"{ %f, %f, %f }", angles.x, angles.y, angles.z];
}

NSString *NSStringFromQuaternion(PLTQuaternion quaternion)
{
	return [NSString stringWithFormat:@"{ %f, %f, %f, %f }", quaternion.w, quaternion.x, quaternion.y, quaternion.z];
}


@interface PLTOrientationTrackingInfo()

@property(nonatomic, readwrite)	PLTEulerAngles	rawEulerAngles;
@property(nonatomic, readwrite)	PLTQuaternion	rawQuaternion;
@property(nonatomic, readwrite)	PLTEulerAngles	referenceEulerAngles;
@property(nonatomic, readwrite)	PLTQuaternion	referenceQuaternion;

@end


@implementation PLTOrientationTrackingInfo

@dynamic quaternion;
@dynamic eulerAngles;
@dynamic rawEulerAngles;
@dynamic referenceEulerAngles;

- (PLTQuaternion)quaternion
{
	// apply cal
	
	PLTQuaternion inverseReferenceQuaternion = InverseQuaternion(self.referenceQuaternion);
	PLTQuaternion calibratedQuaternion = MultipliedQuaternions(self.rawQuaternion, inverseReferenceQuaternion);
	return calibratedQuaternion;
}

- (PLTEulerAngles)eulerAngles
{
	return EulerAnglesFromQuaternion(self.quaternion);
}

- (PLTEulerAngles)rawEulerAngles
{
	return EulerAnglesFromQuaternion(self.rawQuaternion);
}

- (PLTEulerAngles)referenceEulerAngles
{
	return EulerAnglesFromQuaternion(self.referenceQuaternion);
}

#pragma mark - API Internal

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp
   rawQuaternion:(PLTQuaternion)rawQuaternion referenceQuaternion:(PLTQuaternion)referenceQuaternion
{
	self = [super initWithRequestType:requestType timestamp:timestamp];
	self.rawQuaternion = rawQuaternion;
	self.referenceQuaternion = referenceQuaternion;
	return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PLTOrientationTrackingInfo *)info
{
	
	return EulerAnglesAreEqual(info.eulerAngles, self.eulerAngles);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<PLTOrientationTrackingInfo: %p> {\n\trequestType: %u\n\ttimestamp: %@\n\teulerAngles: %@\n\tquaternion: %@\n\trawEulerAngles: %@"
			@"\n\trawQuaternion: %@\n\treferenceEulerAngles: %@\n\treferenceQuaternion: %@\n}",
			self, self.requestType, self.timestamp,
			NSStringFromEulerAngles(self.eulerAngles), NSStringFromQuaternion(self.quaternion),
			NSStringFromEulerAngles(self.rawEulerAngles), NSStringFromQuaternion(self.rawQuaternion),
			NSStringFromEulerAngles(self.referenceEulerAngles), NSStringFromQuaternion(self.referenceQuaternion)];
}

@end
