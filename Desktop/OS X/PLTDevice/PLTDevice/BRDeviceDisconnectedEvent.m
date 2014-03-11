//
//  BRDeviceDisconnectedEvent.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDeviceDisconnectedEvent.h"


@interface BRDeviceDisconnectedEvent ()

@property(nonatomic,assign,readwrite) uint8_t port;

@end


@implementation BRDeviceDisconnectedEvent

#pragma mark - Public

- (void)parseData
{
    uint8_t port;
    [[self.data subdataWithRange:NSMakeRange(8, sizeof(uint8_t))] getBytes:&port length:sizeof(uint8_t)];
    self.port = port;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDeviceDisconnectedEvent %p> port=%d",
            self, self.port];
}

@end
