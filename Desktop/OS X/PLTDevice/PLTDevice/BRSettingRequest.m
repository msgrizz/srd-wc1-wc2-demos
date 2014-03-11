//
//  BRCommandRequest.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


@interface BRSettingRequest ()

@property(nonatomic,strong,readwrite)   NSData  *data;

@end


@implementation BRSettingRequest

#pragma mark - Public

+ (BRSettingRequest *)request
{
    BRSettingRequest *request = [[[super class] alloc] init];
    return request;
}

- (void)parseData
{
    
}

@end
