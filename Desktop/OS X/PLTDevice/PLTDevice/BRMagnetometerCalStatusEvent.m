//
//  BRMagnetometerCalStatus.m
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMagnetometerCalStatusEvent.h"


@interface BRMagnetometerCalStatusEvent ()

@property(nonatomic,assign,readwrite) BOOL isCalibrated;

@end


@implementation BRMagnetometerCalStatusEvent

#pragma mark - Public

- (void)parseData
{
    uint8_t cal;
    [[self.data subdataWithRange:NSMakeRange(15, sizeof(uint8_t))] getBytes:&cal length:sizeof(uint8_t)];
    self.isCalibrated = cal;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRMagnetometerCalStatus %p> isCalibrated=%@",
            self, (self.isCalibrated ? @"YES" : @"NO")];
}

@end
