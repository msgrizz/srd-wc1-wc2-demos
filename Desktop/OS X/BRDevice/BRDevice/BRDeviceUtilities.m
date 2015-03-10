//
//  BRDeviceUtilities.m
//  BRDevice
//
//  Created by Morgan Davis on 1/13/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRDeviceUtilities.h"


NSData *BRDeviceDataFromHexString(NSString *hexString)
{
	NSString *str = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSMutableData *data= [[NSMutableData alloc] init];
	unsigned char whole_byte;
	char byte_chars[3] = {'\0','\0','\0'};
	for (int i = 0; i < ([str length] / 2); i++) {
		byte_chars[0] = [str characterAtIndex:i*2];
		byte_chars[1] = [str characterAtIndex:i*2+1];
		whole_byte = strtol(byte_chars, NULL, 16);
		[data appendBytes:&whole_byte length:1]; 
	}
	return data;
}


NSString *BRDeviceHexStringFromData(NSData *data, unsigned int byteSpacing)
{
	const unsigned char* bytes = (const unsigned char*)[data bytes];
	NSUInteger nbBytes = [data length];
	//If spaces is true, insert a space every this many input bytes (twice this many output characters).
	NSUInteger spaceEveryThisManyBytes = byteSpacing;
	NSUInteger strLen = 2*nbBytes + (byteSpacing>0 ? nbBytes/spaceEveryThisManyBytes : 0);
	
	NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:strLen];
	for(NSUInteger i=0; i<nbBytes; ) {
		[hex appendFormat:@"%02X", bytes[i]];
		//We need to increment here so that the every-n-bytes computations are right.
		++i;
		
		if (byteSpacing>0) {
			if (i % spaceEveryThisManyBytes == 0) [hex appendString:@" "];
		}
	}
	return hex;
}

NSString *BRDeviceDescriptionFromArrayOfShortIntegers(NSArray *array)
{
	if ([array count]) {
		NSMutableString *str = [@"[" mutableCopy];
		for (int i = 0; i<[array count]; i++) {
			NSNumber *numNum = array[i];
			uint16_t num = [numNum unsignedShortValue];
			if (i==[array count]-1) { // at the end
				[str appendFormat:@"0x%04X]", num];
			}
			else {
				[str appendFormat:@"0x%04X, ", num];
			}
		}
		return str;
	}
	return @"[]";
}

BRMessageType BRDeviceMessageTypeFromMessageData(NSData *data)
{
	uint8_t messageType;
	NSData *messageTypeData = [data subdataWithRange:NSMakeRange(5, sizeof(uint8_t))];
	[messageTypeData getBytes:&messageType length:sizeof(uint8_t)];
	messageType &= 0x0F; // messageType is actually the second nibble in byte 5
	return messageType;
}

uint16_t BRDeviceDeckardIDFromMessageData(NSData *data)
{
	NSData *payload = [data subdataWithRange:NSMakeRange(6, sizeof(uint16_t))];
	return BRDeviceDeckardIDFromMessagePayload(payload);
}

uint16_t BRDeviceDeckardIDFromMessagePayload(NSData *payload)
{
	uint16_t deckardID;
	NSData *deckardIDData = [payload subdataWithRange:NSMakeRange(0, sizeof(uint16_t))];
	[deckardIDData getBytes:&deckardID length:sizeof(uint16_t)];
	return ntohs(deckardID);
}

uint16_t BRDeviceExceptionIDFromMessageData(NSData *data)
{
	uint16_t exceptionID;
	NSData *exceptionIDData = [data subdataWithRange:NSMakeRange(8, sizeof(uint16_t))];
	[exceptionIDData getBytes:&exceptionID length:sizeof(uint16_t)];
	return ntohs(exceptionID);
}
