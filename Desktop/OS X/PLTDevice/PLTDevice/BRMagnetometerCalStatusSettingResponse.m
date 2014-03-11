//
//  BRMagnetometerCalStatusSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMagnetometerCalStatusSettingResponse.h"


@interface BRMagnetometerCalStatusSettingResponse ()

@property(nonatomic,assign,readwrite) BOOL isCalibrated;

@end


@implementation BRMagnetometerCalStatusSettingResponse

#pragma mark - Public

- (void)parseData
{
    uint8_t cal;
    [[self.data subdataWithRange:NSMakeRange(14, sizeof(uint8_t))] getBytes:&cal length:sizeof(uint8_t)];
    self.isCalibrated = cal;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRMagnetometerCalStatusSettingResponse %p> isCalibrated=%@",
            self, (self.isCalibrated ? @"YES" : @"NO")];
}

@end
