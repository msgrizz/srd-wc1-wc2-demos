//
//  BRCommandResponse.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"
#import "BRIncomingMessage_Private.h"


@implementation BRSettingResponse

#pragma mark - Public

+ (BRSettingResponse *)settingResponseWithData:(NSData *)data;
{
    BRSettingResponse *response = [[[super class] alloc] init];
	response.data = data;
    return response;
}

#pragma mark - Private

- (BRMessageType)type
{
	return BRMessageTypeSettingResultSuccess;
}

@end
