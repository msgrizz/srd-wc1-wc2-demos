//
//  BRPedometerEvent.m
//  BTSniffer
//
//  Created by Davis, Morgan on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRPedometerEvent.h"


@interface BRPedometerEvent ()

@property(nonatomic,assign,readwrite) NSUInteger steps;

@end


@implementation BRPedometerEvent

#pragma mark - Public

+ (BREvent *)eventWithData:(NSData *)data
{
    BRPedometerEvent *event = [[BRPedometerEvent alloc] initWithData:data];
    return event;
}



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
    return [NSString stringWithFormat:@"<BRPedometerEvent %p> steps=%lu",
            self, (unsigned long)self.steps];
}

@end
