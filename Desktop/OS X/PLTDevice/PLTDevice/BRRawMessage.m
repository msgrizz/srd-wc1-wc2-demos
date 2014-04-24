//
//  BRRawMessage.m
//  PLTDevice
//
//  Created by Morgan Davis on 4/1/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRawMessage.h"


@implementation BRRawMessage

#pragma mark - Public

+ (BRRawMessage *)messageWithData:(NSData *)data
{
    BRRawMessage *message = [[BRRawMessage alloc] init];
    message.data = data;
    return message;
}

@end
