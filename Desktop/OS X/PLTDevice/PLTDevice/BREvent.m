//
//  BREvent.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"
#import "BRIncomingMessage_Private.h"


@implementation BREvent

#pragma mark - Public

//+ (BREvent *)eventWithData:(NSData *)data
+ (BRIncomingMessage *)messageWithData:(NSData *)data
{
    BREvent *event = [[[super class] alloc] init];
	event.data = data;
    return event;
}

#pragma mark - Private

- (BRMessageType)type
{
	return BRMessageTypeEvent;
}

@end
