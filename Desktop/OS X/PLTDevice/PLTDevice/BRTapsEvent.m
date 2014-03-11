//
//  BRTapsEvent.m
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTapsEvent.h"


@interface BRTapsEvent ()

@property(nonatomic,assign,readwrite) uint16_t          taps;
@property(nonatomic,assign,readwrite) PLTTapDirection   direction;

@end


@implementation BRTapsEvent

#pragma mark - Public

- (void)parseData
{
    uint16_t taps;
    uint16_t direction;

    [[self.data subdataWithRange:NSMakeRange(14, sizeof(uint16_t))] getBytes:&direction length:sizeof(uint16_t)];
    [[self.data subdataWithRange:NSMakeRange(16, sizeof(uint16_t))] getBytes:&taps length:sizeof(uint16_t)];
    
    taps = ntohs(taps);
    direction = ntohs(direction);

    self.taps = taps;
    self.direction = direction;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTapsEvent %p> taps=%d, direction=%d",
            self, self.taps, self.direction];
}

@end
