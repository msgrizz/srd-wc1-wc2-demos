//
//  BRPedometerEvent.m
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPedometerEvent.h"
#import "BRIncomingMessage_Private.h"


@interface BRPedometerEvent ()

@property(nonatomic,assign,readwrite) uint32_t steps;

@end


@implementation BRPedometerEvent

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
    return [NSString stringWithFormat:@"<BRPedometerEvent %p> steps=%d",
            self, self.steps];
}

@end
