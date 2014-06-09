//
//  BRTapsEvent.m
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTapsEvent.h"
#import "BRIncomingMessage_Private.h"


@interface BRTapsEvent ()

@property(nonatomic,assign,readwrite) uint8_t		count;
@property(nonatomic,assign,readwrite) uint8_t		direction;

@end


@implementation BRTapsEvent

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
    uint8_t taps;
    uint8_t direction;

    [[self.data subdataWithRange:NSMakeRange(14, sizeof(uint8_t))] getBytes:&direction length:sizeof(uint8_t)];
    [[self.data subdataWithRange:NSMakeRange(15, sizeof(uint8_t))] getBytes:&taps length:sizeof(uint8_t)];
    
    self.count = taps;
    self.direction = direction;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTapsEvent %p> taps=%d, direction=%d",
            self, self.count, self.direction];
}

@end
