//
//  BRQueryWearingStateSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRWearingStateSettingResponse.h"
#import "BRIncomingMessage_Private.h"


@interface BRWearingStateSettingResponse ()

@property(nonatomic,readwrite) BOOL isBeingWorn;

@end


@implementation BRWearingStateSettingResponse

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
    uint8_t w;
    [[self.data subdataWithRange:NSMakeRange(8, sizeof(uint8_t))] getBytes:&w length:sizeof(uint8_t)];
    self.isBeingWorn = (BOOL)w;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRWearingStateSettingResponse %p> isBeingWorn=%@",
            self, (self.isBeingWorn ? @"YES" : @"NO")];
}

@end
