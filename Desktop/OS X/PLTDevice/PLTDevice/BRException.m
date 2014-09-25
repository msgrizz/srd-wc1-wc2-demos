//
//  BRException.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRException.h"
#import "BRIncomingMessage_Private.h"


@interface BRException()

@property(nonatomic,assign,readwrite)	uint16_t  exceptionID;

@end


@implementation BRException

#pragma mark - Public

+ (BRException *)exceptionWithData:(NSData *)data
{
    BRException *exception = [[[super class] alloc] init];
	exception.data = data;
    return exception;
}

#pragma mark - Private

- (void)parseData
{
	[super parseData];
	
	uint16_t exceptionID;
	[[self.payload subdataWithRange:NSMakeRange(0, sizeof(uint16_t))] getBytes:&exceptionID length:sizeof(uint16_t)];
	self.exceptionID = ntohs(exceptionID);
}

- (BRMessageType)type
{
	//return BRMessageTypeSettingResultSuccess;
	return 0; // whatever
}

@end
