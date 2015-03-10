//
//  BRSettingResult.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"
#import "BRIncomingMessage_Private.h"


@implementation BRSettingResult

#pragma mark - Public

//+ (BRSettingResult *)settingResultWithData:(NSData *)data
+ (BRIncomingMessage *)messageWithData:(NSData *)data
{
    BRSettingResult *response = [[[super class] alloc] init];
	response.data = data;
    return response;
}

#pragma mark - Private

- (BRMessageType)type
{
	return BRMessageTypeSettingResultSuccess;
}

@end
