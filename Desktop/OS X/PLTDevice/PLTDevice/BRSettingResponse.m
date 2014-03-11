//
//  BRCommandResponse.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"


@interface BRSettingResponse ()

@property(nonatomic,strong,readwrite)   NSData  *data;

@end


@implementation BRSettingResponse

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

+ (BRSettingResponse *)settingResponseWithData:(NSData *)data;
{
    BRSettingResponse *response = [[[super class] alloc] initWithData:data];
    return response;
}

- (id)initWithData:(NSData *)data
{
    self = [super init];
    self.data = data;
    return self;
}

@end
