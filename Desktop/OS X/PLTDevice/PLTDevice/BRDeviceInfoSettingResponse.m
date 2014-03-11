//
//  BRDeviceInfoSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDeviceInfoSettingResponse.h"


@interface BRDeviceInfoSettingResponse ()

@property(nonatomic,strong,readwrite) NSArray   *majorHardwareVersions;
@property(nonatomic,strong,readwrite) NSArray   *minorHardwareVersions;
@property(nonatomic,strong,readwrite) NSArray   *majorSoftwareVersions;
@property(nonatomic,strong,readwrite) NSArray   *minorSoftwareVersions;
@property(nonatomic,strong,readwrite) NSArray   *supportedServices;

@end


@implementation BRDeviceInfoSettingResponse

#pragma mark - Public

- (void)parseData
{
    uint16_t payloadOffset = 8;
    
    uint16_t majHWLen;
    [[self.data subdataWithRange:NSMakeRange(payloadOffset, sizeof(uint16_t))] getBytes:&majHWLen length:sizeof(uint16_t)];
    majHWLen = ntohs(majHWLen);
    
    uint8_t majHW[majHWLen];
    [[self.data subdataWithRange:NSMakeRange(payloadOffset + sizeof(uint16_t), majHWLen)] getBytes:majHW length:sizeof(majHWLen)];
    
    for (int v=0; v<majHWLen; v++) {
        NSLog(@"majHW[%d] = %d", v, majHW[v]);
    }
    
//    uint16_t minHWLen;
//    [[self.data subdataWithRange:NSMakeRange(payloadOffset + sizeof(uint16_t) + majHWLen, sizeof(uint16_t))] getBytes:&minHWLen length:sizeof(uint16_t)];
//    minHWLen = ntohs(minHWLen);
//    
//    uint16_t majSWLen;
//    [[self.data subdataWithRange:NSMakeRange(payloadOffset + sizeof(uint16_t) + majHWLen + sizeof(uint16_t) + minHWLen, sizeof(uint16_t))] getBytes:&majSWLen length:sizeof(uint16_t)];
//    majSWLen = ntohs(majSWLen);
//    
//    uint16_t minSWLen;
//    [[self.data subdataWithRange:NSMakeRange(payloadOffset + sizeof(uint16_t) + majHWLen + sizeof(uint16_t) + minHWLen + sizeof(uint16_t) + majSWLen, sizeof(uint16_t))] getBytes:&minSWLen length:sizeof(uint16_t)];
//    minSWLen = ntohs(minSWLen);


}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDeviceInfoSettingResponse %p> majorHardwareVersions=%@, minorHardwareVersions=%@, majorSoftwareVersions=%@, minorSoftwareVersions=%@, supportedServices=%@",
            self, self.majorHardwareVersions, self.minorHardwareVersions, self.majorSoftwareVersions, self.minorSoftwareVersions, self.supportedServices];
}

@end
