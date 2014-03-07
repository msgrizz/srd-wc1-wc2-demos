//
//  BROrientationTrackingSettingResponse.m
//  PLTDevice
//
//  Created by Davis, Morgan on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROrientationTrackingSettingResponse.h"


@interface BROrientationTrackingSettingResponse ()

@end


@implementation BROrientationTrackingSettingResponse

#pragma mark - Public

+ (BROrientationTrackingSettingResponse *)settingResponseWithData:(NSData *)data
{
    BROrientationTrackingSettingResponse *response = [[BROrientationTrackingSettingResponse alloc] initWithData:data];
    return response;
}

- (void)parseData
{
    NSLog(@"data: %@", self.data);
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BROrientationTrackingSettingResponse %p>",
            self];
}

@end
