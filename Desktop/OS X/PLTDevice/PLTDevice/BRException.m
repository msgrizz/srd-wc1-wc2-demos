//
//  BRException.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRException.h"


@implementation BRException

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

+ (BRException *)exceptionWithData:(NSData *)data
{
    BRException *exception = [[[super class] alloc] initWithData:data];
    return exception;
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
