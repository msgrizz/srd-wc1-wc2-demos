//
//  BRTapsSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTapsSettingResponse.h"
#import "BRIncomingMessage_Private.h"


@interface BRTapsSettingResponse ()

@property(nonatomic,assign,readwrite) uint8_t   count;
@property(nonatomic,assign,readwrite) uint8_t   direction;

@end


@implementation BRTapsSettingResponse

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
    uint8_t taps;
    uint8_t direction;
    
    [[self.data subdataWithRange:NSMakeRange(14, sizeof(uint8_t))] getBytes:&direction length:sizeof(uint8_t)];
    [[self.data subdataWithRange:NSMakeRange(15, sizeof(uint8_t))] getBytes:&taps length:sizeof(uint8_t)];
    
//    taps = ntohs(taps);
//    direction = ntohs(direction);
    
    self.count = taps;
    self.direction = direction;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTapsSettingResponse %p> taps=%lu, direction=%d",
            self, (unsigned long)self.count, self.direction];
}

@end
