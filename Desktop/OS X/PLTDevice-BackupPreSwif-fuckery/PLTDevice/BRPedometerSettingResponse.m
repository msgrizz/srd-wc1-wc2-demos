//
//  BRPedometerSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPedometerSettingResponse.h"
#import "BRIncomingMessage_Private.h"


@interface BRPedometerSettingResponse ()

@property(nonatomic,assign,readwrite) uint32_t steps;

@end


@implementation BRPedometerSettingResponse

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
    uint32_t steps;
    [[self.payload subdataWithRange:NSMakeRange(8, sizeof(uint32_t))] getBytes:&steps length:sizeof(uint32_t)];
    steps = ntohl(steps);
    self.steps = steps;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRPedometerSettingResponse %p> steps=%lu",
            self, (unsigned long)self.steps];
}

@end
