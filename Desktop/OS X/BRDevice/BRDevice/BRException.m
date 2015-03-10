//
//  BRException.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRException.h"
#import "BRIncomingMessage_Private.h"


@implementation BRException

#pragma mark - Public

+ (BRException *)exceptionWithData:(NSData *)data
{
    BRException *exception = [[[super class] alloc] init];
	exception.data = data;
    return exception;
}

#pragma mark - Private

- (BRMessageType)type
{
	return 0; // whatever
}

@end
