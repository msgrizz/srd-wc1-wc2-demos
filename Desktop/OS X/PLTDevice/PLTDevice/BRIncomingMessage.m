//
//  BRIncomingMessage.m
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIncomingMessage.h"
#import "BRIncomingMessage_Private.h"
#import "BRMessage_Private.h"



#import "NSData+HexStrings.h"


@implementation BRIncomingMessage

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

@dynamic payload;

- (void)setPayload:(NSData *)payload
{
    _payload = payload;
}

- (NSData *)payload
{
    return _payload;
}

#pragma mark - Public

+ (BRIncomingMessage *)messageWithData:(NSData *)data;
{
    BRIncomingMessage *message = [[[super class] alloc] init];
	message.data = data;
    return message;
}

#pragma mark - Private

- (void)parseData
{
	// set address, payload
	
	NSString *address = [[self.data subdataWithRange:NSMakeRange(2, sizeof(uint32_t))] hexStringWithSpaceEvery:0];
	self.address = [address substringToIndex:6];
	
	uint8_t type;
	[[self.data subdataWithRange:NSMakeRange(5, sizeof(uint8_t))] getBytes:&type length:sizeof(uint8_t)];
	type <<= 4;
	type >>= 4;
	self.type = type;
	
	// 1 nibble packet type
	// 3 nibbles length
	// 7 nibbles address
	// 1 nibble type
	// X bytes payload
	
	self.payload = [self.data subdataWithRange:NSMakeRange(6, [self.data length] - 6)];
}

@end
