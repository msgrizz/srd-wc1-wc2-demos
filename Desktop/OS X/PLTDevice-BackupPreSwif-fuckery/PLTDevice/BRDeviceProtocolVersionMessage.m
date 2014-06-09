//
//  BRDeviceProtocolVersionMessage.m
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDeviceProtocolVersionMessage.h"
#import "BRIncomingMessage_Private.h"


@interface BRDeviceProtocolVersionMessage ()

@property(nonatomic,readwrite)			uint8_t		minimumVersion;
@property(nonatomic,readwrite)			uint8_t		maximumVersion;

@end


@implementation BRDeviceProtocolVersionMessage

#pragma mark - Private

- (void)parseData
{
	[super parseData];
	
	uint8_t vers;
    [[self.payload subdataWithRange:NSMakeRange(0, sizeof(uint8_t))] getBytes:&vers length:sizeof(uint8_t)];
    self.minimumVersion = vers;
	[[self.payload subdataWithRange:NSMakeRange(1, sizeof(uint8_t))] getBytes:&vers length:sizeof(uint8_t)];
    self.maximumVersion = vers;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDeviceProtocolVersionMessage %p> minimumVersion=%d, maximumVersion=%d",
            self, self.minimumVersion, self.maximumVersion];
}

@end
