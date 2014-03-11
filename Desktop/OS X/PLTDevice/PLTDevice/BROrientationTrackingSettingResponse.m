//
//  BROrientationTrackingSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROrientationTrackingSettingResponse.h"


@interface BROrientationTrackingSettingResponse () {
    PLTQuaternion _rawQuaternion;
}

@property(nonatomic,readwrite) PLTQuaternion     rawQuaternion;

@end


@implementation BROrientationTrackingSettingResponse

@dynamic rawEulerAngles;
@dynamic rawQuaternion;

#pragma mark - Public

+ (BROrientationTrackingSettingResponse *)settingResponseWithData:(NSData *)data
{
    BROrientationTrackingSettingResponse *response = [[BROrientationTrackingSettingResponse alloc] initWithData:data];
    return response;
}

- (void)parseData
{
    int32_t w, x, y, z;
    
    [[self.data subdataWithRange:NSMakeRange(14, sizeof(int16_t))] getBytes:&w length:sizeof(int16_t)];
    [[self.data subdataWithRange:NSMakeRange(16, sizeof(int16_t))] getBytes:&x length:sizeof(int16_t)];
    [[self.data subdataWithRange:NSMakeRange(18, sizeof(int16_t))] getBytes:&y length:sizeof(int16_t)];
    [[self.data subdataWithRange:NSMakeRange(20, sizeof(int16_t))] getBytes:&z length:sizeof(int16_t)];
    
    w = (int32_t)ntohs((uint16_t)w);
    x = (int32_t)ntohs((uint16_t)x);
    y = (int32_t)ntohs((uint16_t)y);
    z = (int32_t)ntohs((uint16_t)z);
    
    if (w > 32767) w -= 65536;
    if (x > 32767) x -= 65536;
    if (y > 32767) y -= 65536;
    if (z > 32767) z -= 65536;
    
    double fw = ((double)w) / 16384.0f;
    double fx = ((double)x) / 16384.0f;
    double fy = ((double)y) / 16384.0f;
    double fz = ((double)z) / 16384.0f;
	
    PLTQuaternion q = (PLTQuaternion){fw, fx, fy, fz};
    if (q.w>1.0001f || q.x>1.0001f || q.y>1.0001f || q.z>1.0001f) {
        NSLog(@"Bad quaternion! %@", NSStringFromQuaternion(q));
    }
    else {
        self.rawQuaternion = (PLTQuaternion){fw, fx, fy, fz};
    }
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
    return [NSString stringWithFormat:@"<BROrientationTrackingSettingResponse %p> quaternion=%@, eulerAngles=%@",
            self, NSStringFromQuaternion(self.rawQuaternion), NSStringFromEulerAngles(self.rawEulerAngles)];
}

@end
