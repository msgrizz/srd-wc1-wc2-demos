//
//  BRTapsSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTapsSettingResponse.h"


@interface BRTapsSettingResponse ()

@property(nonatomic,assign,readwrite) uint16_t          taps;
@property(nonatomic,assign,readwrite) PLTTapDirection   direction;

@end


@implementation BRTapsSettingResponse

#pragma mark - Public

- (void)parseData
{
    uint8_t taps;
    uint8_t direction;
    
    [[self.data subdataWithRange:NSMakeRange(14, sizeof(uint8_t))] getBytes:&direction length:sizeof(uint8_t)];
    [[self.data subdataWithRange:NSMakeRange(15, sizeof(uint8_t))] getBytes:&taps length:sizeof(uint8_t)];
    
//    taps = ntohs(taps);
//    direction = ntohs(direction);
    
    self.taps = taps;
    self.direction = direction;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTapsSettingResponse %p> taps=%lu, direction=%d",
            self, (unsigned long)self.taps, self.direction];
}

@end
