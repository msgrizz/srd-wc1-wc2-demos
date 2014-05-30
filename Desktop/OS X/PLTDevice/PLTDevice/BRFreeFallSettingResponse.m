//
//  BRFreeFallSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRFreeFallSettingResponse.h"
#import "BRIncomingMessage_Private.h"


@interface BRFreeFallSettingResponse ()

@property(nonatomic,assign,readwrite) BOOL isInFreeFall;

@end


@implementation BRFreeFallSettingResponse

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
    uint8_t ff;
    [[self.data subdataWithRange:NSMakeRange(14, sizeof(uint8_t))] getBytes:&ff length:sizeof(uint8_t)];
    self.isInFreeFall = ff;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRFreeFallSettingResponse %p> isInFreeFall=%@",
            self, (self.isInFreeFall ? @"YES" : @"NO")];
}

@end
