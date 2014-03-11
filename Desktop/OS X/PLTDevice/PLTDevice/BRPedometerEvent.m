//
//  BRPedometerEvent.m
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPedometerEvent.h"


@interface BRPedometerEvent ()

@property(nonatomic,assign,readwrite) uint16_t steps;

@end


@implementation BRPedometerEvent

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
    return [NSString stringWithFormat:@"<BRPedometerEvent %p> steps=%d",
            self, self.steps];
}

@end
