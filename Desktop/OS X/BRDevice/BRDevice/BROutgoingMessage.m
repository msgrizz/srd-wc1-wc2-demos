//
//  BROutgoingMessage.m
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROutgoingMessage.h"
#import "BRMessage_Private.h"
#import "BROutgoingMessage_Private.h"
#import "BRDeviceUtilities.h"


@implementation BROutgoingMessage

@dynamic data;
- (NSData *)data
{
	NSString *hexString = [NSString stringWithFormat:@"1 %03X %@ %1X",
						   self.length,		// length
						   self.address,	// address
						   self.type		// type
						   ];	
	NSMutableData *data = [BRDeviceDataFromHexString(hexString) mutableCopy];
	[data appendData:self.payload];
	return data;
}

- (NSData *)payload
{
	NSMutableData *payloadData = [NSMutableData data];
	
	uint16_t deckardID = [self deckardID];
	if (deckardID != 0) {
		deckardID = htons(deckardID);
		[payloadData appendBytes:&deckardID length:sizeof(uint16_t)];
	}

	for (NSDictionary *item in [self payloadDescriptors]) {
		NSString *name = item[@"name"];
		BRPayloadItemType type = [item[@"type"] intValue];
		NSValue *value = [self valueForKey:name];
		
		switch (type) {
			case BRPayloadItemTypeBoolean: {
				BOOL unpacked;
				[value getValue:&unpacked];
				[payloadData appendBytes:&unpacked length:sizeof(BOOL)];
				break; }
				
			case BRPayloadItemTypeByte: {
				uint8_t unpacked;
				[value getValue:&unpacked];
				[payloadData appendBytes:&unpacked length:sizeof(uint8_t)];
				break; }
				
			case BRPayloadItemTypeShort: {
				int16_t unpacked;
				[value getValue:&unpacked];
				unpacked = htons(unpacked);
				[payloadData appendBytes:&unpacked length:sizeof(int16_t)];
				break; }
				
			case BRPayloadItemTypeUnsignedShort: {
				uint16_t unpacked;
				[value getValue:&unpacked];
				unpacked = htons(unpacked);
				[payloadData appendBytes:&unpacked length:sizeof(uint16_t)];
				break; }
				
			case BRPayloadItemTypeLong:
			case BRPayloadItemTypeInt: {
				int32_t unpacked;
				[value getValue:&unpacked];
				unpacked = htonl(unpacked);
				[payloadData appendBytes:&unpacked length:sizeof(int32_t)];
				break; }
				
			case BRPayloadItemTypeUnsignedLong:
			case BRPayloadItemTypeUnsignedInt: {
				uint32_t unpacked;
				[value getValue:&unpacked];
				unpacked = htonl(unpacked);
				[payloadData appendBytes:&unpacked length:sizeof(uint32_t)];
				break; }
				
			case BRPayloadItemTypeByteArray: {
				//NSData *data = [value pointerValue];
				NSData *data = (NSData *)value;
				uint16_t len = [data length];
				len = htons(len);
				[payloadData appendBytes:&len length:sizeof(uint16_t)];
				[payloadData appendData:data];
				break; }
				
			case BRPayloadItemTypeShortArray: {
				// need to unpack shorts and htons them
				
				//NSData *data = [value pointerValue];
				NSData *data = (NSData *)value;
				uint16_t len = [data length];
				len = htons(len);
				uint16_t shorts[len];
				[data getBytes:shorts];
				for (uint16_t i=0; i<len; i++) {
					shorts[i] = htons(shorts[i]);
				}
				data = [NSData dataWithBytes:shorts length:len*2];
				[payloadData appendBytes:&len length:sizeof(uint16_t)];
				[payloadData appendData:data];
				break; }
				
			case BRPayloadItemTypeString: {
				
				break; }
		}
	}
	
	return payloadData;
}

@end
