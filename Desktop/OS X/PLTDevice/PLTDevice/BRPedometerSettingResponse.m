//
//  BRPedometerSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPedometerSettingResponse.h"


@interface BRPedometerSettingResponse ()

@property(nonatomic,assign,readwrite) uint16_t steps;

@end


@implementation BRPedometerSettingResponse

#pragma mark - Public

- (void)parseData
{
    uint16_t steps;
    [[self.data subdataWithRange:NSMakeRange(14, sizeof(uint16_t))] getBytes:&steps length:sizeof(uint16_t)];
    steps = ntohs(steps);
    self.steps = steps;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPedometerSettingResponse %p> steps=%lu",
            self, (unsigned long)self.steps];
}

@end
