//
//  BROrientationTrackingEvent.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROrientationTrackingEvent.h"
#import "BRIncomingMessage_Private.h"


@interface BROrientationTrackingEvent ()

@property(nonatomic,assign,readwrite) BRQuaternion		quaternion;

@end


@implementation BROrientationTrackingEvent

#pragma mark - Public

- (void)parseData
{
	[super parseData];

	int32_t w, x, y, z;
    
    [[self.data subdataWithRange:NSMakeRange(14, sizeof(int32_t))] getBytes:&w length:sizeof(int32_t)];
    [[self.data subdataWithRange:NSMakeRange(18, sizeof(int32_t))] getBytes:&x length:sizeof(int32_t)];
    [[self.data subdataWithRange:NSMakeRange(22, sizeof(int32_t))] getBytes:&y length:sizeof(int32_t)];
    [[self.data subdataWithRange:NSMakeRange(26, sizeof(int32_t))] getBytes:&z length:sizeof(int32_t)];
	
	w = ntohl(w);
	x = ntohl(x);
	y = ntohl(y);
	z = ntohl(z);

    if (w > 32767) w -= 65536;
    if (x > 32767) x -= 65536;
    if (y > 32767) y -= 65536;
    if (z > 32767) z -= 65536;
    
    double fw = ((double)w) / 16384.0f;
    double fx = ((double)x) / 16384.0f;
    double fy = ((double)y) / 16384.0f;
    double fz = ((double)z) / 16384.0f;
	
    BRQuaternion q = (BRQuaternion){fw, fx, fy, fz};
    if (q.w>1.0001f || q.x>1.0001f || q.y>1.0001f || q.z>1.0001f) {
        NSLog(@"Bad quaternion! { %f, %f, %f, %f }", q.w, q.x, q.y, q.z);
    }
    else {
        self.quaternion = (BRQuaternion){fw, fx, fy, fz};
    }
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROrientationTrackingEvent %p> quaternion={ %f, %f, %f, %f }",
            self, self.quaternion.w, self.quaternion.x, self.quaternion.y, self.quaternion.z];
}

@end
