//
//  BROrientationTrackingSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROrientationTrackingSettingResponse.h"
#import "BRIncomingMessage_Private.h"


@interface BROrientationTrackingSettingResponse ()

@property(nonatomic,assign,readwrite) double	*quaternion;

@end


@implementation BROrientationTrackingSettingResponse

#pragma mark - Public

+ (BROrientationTrackingSettingResponse *)settingResponseWithData:(NSData *)data
{
    BROrientationTrackingSettingResponse *response = [[BROrientationTrackingSettingResponse alloc] init];
	response.data = data;
    return response;
}

- (void)parseData
{
	[super parseData];
	
	// 2-byte components
//	int16_t w, x, y, z;
//	
//	[[self.data subdataWithRange:NSMakeRange(14, sizeof(int16_t))] getBytes:&w length:sizeof(int16_t)];
//	[[self.data subdataWithRange:NSMakeRange(16, sizeof(int16_t))] getBytes:&x length:sizeof(int16_t)];
//	[[self.data subdataWithRange:NSMakeRange(18, sizeof(int16_t))] getBytes:&y length:sizeof(int16_t)];
//	[[self.data subdataWithRange:NSMakeRange(20, sizeof(int16_t))] getBytes:&z length:sizeof(int16_t)];
//	
//	w = ntohs(w);
//	x = ntohs(x);
//	y = ntohs(y);
//	z = ntohs(z);
	
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
	
//	BRQuaternion q = (BRQuaternion){fw, fx, fy, fz};
//	if (q.w>1.0001f || q.x>1.0001f || q.y>1.0001f || q.z>1.0001f) {
//		NSLog(@"Bad quaternion! { %f, %f, %f, %f }", q.w, q.x, q.y, q.z);
//	}
//	else {
//		self.quaternion = (BRQuaternion){fw, fx, fy, fz};
//	}
	
	double *q = malloc(sizeof(double)*4);
	q[0] = fw;
	q[1] = fx;
	q[2] = fy;
	q[4] = fz;
    if (fw>1.0001f || fx>1.0001f || fy>1.0001f || fz>1.0001f) {
        NSLog(@"Bad quaternion! { %f, %f, %f, %f }", fw, fx, fy, fz);
    }
    else {
		if (self.quaternion) free(self.quaternion);
		self.quaternion = q;
    }
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROrientationTrackingSettingResponse %p> quaternion={ %f, %f, %f, %f }",
            self, self.quaternion[0], self.quaternion[1], self.quaternion[2], self.quaternion[3]];
}

@end
