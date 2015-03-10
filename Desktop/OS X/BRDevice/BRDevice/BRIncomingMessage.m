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
#import "BRDeviceUtilities.h"


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
	
	NSString *address = BRDeviceHexStringFromData([self.data subdataWithRange:NSMakeRange(2, sizeof(uint32_t))], 0);
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
	
	
	// use payloadDescriptors to parse the payload body and populate object properties
	
	NSUInteger offset = 2;
	
	for (NSDictionary *item in [self payloadDescriptors]) {
		NSString *name = item[@"name"];
		BRPayloadItemType type = [item[@"type"] intValue];
		id value;
		
		switch (type) {
			case BRPayloadItemTypeBoolean:
			case BRPayloadItemTypeByte: {
				uint8_t unpacked;
				NSRange range = NSMakeRange(offset, sizeof(uint8_t));
				[self.payload getBytes:&unpacked range:range];
				value = @(unpacked);
				offset += sizeof(uint8_t);
				break; }
				
			case BRPayloadItemTypeShort: {
				int16_t unpacked;
				NSRange range = NSMakeRange(offset, sizeof(int16_t));
				[self.payload getBytes:&unpacked range:range];
				unpacked = htons(unpacked);
				value = @(unpacked);
				offset += sizeof(int16_t);
				break; }
				
			case BRPayloadItemTypeUnsignedShort: {
				uint16_t unpacked;
				NSRange range = NSMakeRange(offset, sizeof(uint16_t));
				[self.payload getBytes:&unpacked range:range];
				unpacked = htons(unpacked);
				value = @(unpacked);
				offset += sizeof(uint16_t);
				break; }
				
			case BRPayloadItemTypeLong:
			case BRPayloadItemTypeInt: {
				int32_t unpacked;
				NSRange range = NSMakeRange(offset, sizeof(int32_t));
				[self.payload getBytes:&unpacked range:range];
				unpacked = htonl(unpacked);
				value = @(unpacked);
				offset += sizeof(int32_t);
				break; }
				
			case BRPayloadItemTypeUnsignedLong:
			case BRPayloadItemTypeUnsignedInt: {
				uint32_t unpacked;
				NSRange range = NSMakeRange(offset, sizeof(uint32_t));
				[self.payload getBytes:&unpacked range:range];
				unpacked = htonl(unpacked);
				value = @(unpacked);
				offset += sizeof(uint32_t);
				break; }
				
			case BRPayloadItemTypeByteArray: {
				uint16_t len;
				NSRange range = NSMakeRange(offset, sizeof(uint16_t));
				[self.payload getBytes:&len range:range];
				len = ntohs(len);
				offset += sizeof(uint16_t);
				range = NSMakeRange(offset, len);
				value = [self.payload subdataWithRange:range];
				offset += len;
				break; }
				
			case BRPayloadItemTypeShortArray: {
				uint16_t len;
				NSRange range = NSMakeRange(offset, sizeof(uint16_t));
				[self.payload getBytes:&len range:range];
				len = ntohs(len);
				offset += sizeof(uint16_t);
				int16_t array[len];
				range = NSMakeRange(offset, len*2);
				[self.payload getBytes:array range:range];
				for (uint16_t i=0; i<len; i++) {
					array[i] = ntohs(array[i]);
				}
				value = [NSData dataWithBytes:array length:len*2];
				offset += len*2;
				break; }
				
			case BRPayloadItemTypeString: {
				
				break; }
		}
		
		if (value) {
			[self setValue:value forKey:name];
		}
	}
}

@end
