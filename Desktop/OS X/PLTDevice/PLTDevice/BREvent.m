//
//  BREvent.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


@implementation BREvent

@dynamic data;

- (void)setData:(NSData *)data
{
    _data = data;
    [self parseData];
}

- (NSData *)data
{
    return _data;
}

#pragma mark - Private

+ (BREvent *)eventWithData:(NSData *)data
{
    BREvent *event = [[[super class] alloc] initWithData:data];
    return event;
}

- (id)initWithData:(NSData *)data
{
    self = [super init];
    self.data = data;
    return self;
}

- (void)parseData
{
    
}

@end
