//
//  BRQueryWearingStateSettingResponse.m
//  PLTDevice
//
//  Created by Davis, Morgan on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRQueryWearingStateSettingResponse.h"


@interface BRQueryWearingStateSettingResponse ()

@property(nonatomic,readwrite) BOOL isBeingWorn;

@end


@implementation BRQueryWearingStateSettingResponse

#pragma mark - Public

+ (BRSettingResponse *)settingResponseWithData:(NSData *)data
{
    BRQueryWearingStateSettingResponse *response = [[BRQueryWearingStateSettingResponse alloc] initWithData:data];
    return response;
}

- (void)parseData
{
    uint8_t w;
    [[self.data subdataWithRange:NSMakeRange(8, sizeof(uint8_t))] getBytes:&w length:sizeof(uint8_t)];
    self.isBeingWorn = (BOOL)w;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRQueryWearingStateSettingResponse %p> isBeingWorn=%@",
            self, (self.isBeingWorn ? @"YES" : @"NO")];
}


@end
