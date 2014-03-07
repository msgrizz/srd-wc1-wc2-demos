//
//  BROrientationTrackingEvent.m
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROrientationTrackingEvent.h"


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
	
	double m22=2*pow(q0,2)+2*pow(q2,2)-1;
	double m21=2*q1*q2-2*q0*q3;
	double m13=2*q1*q3-2*q0*q2;
	double m23=2*q2*q3+2*q0*q1;
	double m33=2*pow(q0,2)+2*pow(q3,2)-1;
	
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

NSString *NSStringFromEulerAngles(PLTEulerAngles angles)
{
	return [NSString stringWithFormat:@"{ %f, %f, %f }", angles.x, angles.y, angles.z];
}

NSString *NSStringFromQuaternion(PLTQuaternion quaternion)
{
	return [NSString stringWithFormat:@"{ %f, %f, %f, %f }", quaternion.w, quaternion.x, quaternion.y, quaternion.z];
}


@interface BROrientationTrackingEvent () {
    PLTQuaternion _rawQuaternion;
}

- (id)initWithData:(NSData *)data;

@property(nonatomic,readwrite) PLTQuaternion     rawQuaternion;

@end


@implementation BROrientationTrackingEvent

@dynamic rawEulerAngles;
@dynamic rawQuaternion;

#pragma mark - Public

+ (BREvent *)eventWithData:(NSData *)data
{
    BROrientationTrackingEvent *event = [[BROrientationTrackingEvent alloc] initWithData:data];
    return event;
}

- (void)parseData
{
    NSLog(@"data: %@", self.data);
    
    uint16_t w, x, y, z;
    
    [[self.data subdataWithRange:NSMakeRange(14, sizeof(uint16_t))] getBytes:&x length:sizeof(uint16_t)];
    [[self.data subdataWithRange:NSMakeRange(16, sizeof(uint16_t))] getBytes:&y length:sizeof(uint16_t)];
    [[self.data subdataWithRange:NSMakeRange(18, sizeof(uint16_t))] getBytes:&z length:sizeof(uint16_t)];
    [[self.data subdataWithRange:NSMakeRange(20, sizeof(uint16_t))] getBytes:&w length:sizeof(uint16_t)];

    w = ntohs(w);
    x = ntohs(x);
    y = ntohs(y);
    z = ntohs(z);
    
    NSLog(@"w: %04X", w);
    NSLog(@"x: %04X", x);
    NSLog(@"y: %04X", y);
    NSLog(@"z: %04X", z);
    
//    PLTQuaternion quaternion = (PLTQuaternion){
//        (float)w/(float)SHRT_MAX,
//        (float)x/(float)SHRT_MAX,
//        (float)y/(float)SHRT_MAX,
//        (float)z/(float)SHRT_MAX };

    PLTQuaternion quaternion = (PLTQuaternion){
        (float)w/((float)SHRT_MAX*2.0),
        (float)x/((float)SHRT_MAX*2.0),
        (float)y/((float)SHRT_MAX*2.0),
        (float)z/((float)SHRT_MAX*2.0) };
    
//    PLTQuaternion quaternion = (PLTQuaternion){
//        (float)w / 16384.0f,
//        (float)x / 16384.0f,
//        (float)y / 16384.0f,
//        (float)z / 16384.0f };
    
    self.rawQuaternion = quaternion;
    
    NSLog(@"quaternion: %@", NSStringFromQuaternion(quaternion));
    NSLog(@"euler angles: %@", NSStringFromEulerAngles(EulerAnglesFromQuaternion(quaternion)));
}

- (PLTEulerAngles)rawEulerAngles
{
    return EulerAnglesFromQuaternion(self.rawQuaternion);
}

- (PLTQuaternion)rawQuaternion
{
    return _rawQuaternion;
}

- (void)setRawQuaternion:(PLTQuaternion)quaternion
{
    _rawQuaternion = quaternion;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROrientationTrackingEvent %p> quaternion=%@, eulerAngles=%@",
            self, NSStringFromQuaternion(self.rawQuaternion), NSStringFromEulerAngles(self.rawEulerAngles)];
}

@end
