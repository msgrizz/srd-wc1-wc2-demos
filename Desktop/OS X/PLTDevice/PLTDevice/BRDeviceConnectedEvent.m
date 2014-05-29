//
//  BRDeviceConnectedEvent.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDeviceConnectedEvent.h"
#import "BRIncomingMessage_Private.h"


@interface BRDeviceConnectedEvent ()

//@property(nonatomic,assign,readwrite) uint32_t  address;
@property(nonatomic,assign,readwrite) uint8_t   port;

@end


@implementation BRDeviceConnectedEvent

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
//    uint32_t address;
//    [[self.data subdataWithRange:NSMakeRange(8, sizeof(uint32_t)-1)] getBytes:&address length:sizeof(uint32_t)-1];
//    self.address = address;
    
    uint8_t port;
    [[self.data subdataWithRange:NSMakeRange(8, sizeof(uint8_t))] getBytes:&port length:sizeof(uint8_t)];
    self.port = port;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDeviceConnectedEvent %p> port=%d",
            self, self.port];
}

@end
