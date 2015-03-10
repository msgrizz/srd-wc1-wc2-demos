//
//  BRCloseSessionMessage.m
//  PLTDevice
//
//  Created by Morgan Davis on 4/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCloseSessionMessage.h"
#import "BRDeviceUtilities.h"
#import "BRMessage_Private.h"


@implementation BRCloseSessionMessage

#pragma mark - Public

+ (BRCloseSessionMessage *)message;
{
    BRCloseSessionMessage *message = [[BRCloseSessionMessage alloc] init];
    return message;
}

//+ (BRCloseSessionMessage *)messageWithAddress:(uint32_t)address
//{
//    BRCloseSessionMessage *message = [[BRCloseSessionMessage alloc] init];
//    message.address = address;
//    return message;
//}

- (BRMessageType)type
{
	return BRMessageTypeCloseSession;
}

#pragma Private

- (NSData *)payload
{
	return [NSData data];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCloseSessionMessage %p>",
            self];
}

@end
