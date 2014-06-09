//
//  BRRawMessage.m
//  PLTDevice
//
//  Created by Morgan Davis on 4/1/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRawMessage.h"
#import "BRMessage_Private.h"


@interface BRRawMessage ()

@property(nonatomic,assign)	BRMessageType	typeOverride;
@property(nonatomic,strong)	NSData			*payloadOverride;

@end


@implementation BRRawMessage

#pragma mark - Public

+ (BRRawMessage *)messageWithType:(BRMessageType)type payload:(NSData *)payload
{
    BRRawMessage *message = [[BRRawMessage alloc] init];
	message.typeOverride = type;
    message.payloadOverride = payload;
    return message;
}

#pragma mark - Private

- (BRMessageType)type
{
	return self.typeOverride;
}

- (NSData *)payload
{
	return self.payloadOverride;
}

@end
