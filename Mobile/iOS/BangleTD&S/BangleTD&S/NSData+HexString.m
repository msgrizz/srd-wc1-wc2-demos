//
//  NSData+HexString.m
//  Shaaaaa
//
//  Created by Morgan Davis on 6/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "NSData+HexString.h"


@implementation NSData (HexString)

+ (NSData *)dataWithHexString:(NSString *)hexString
{
	NSMutableData* data = [NSMutableData dataWithCapacity: [hexString length] / 2];
	
	char* chars = (char*)[hexString UTF8String];
	
	unsigned char value;
	
	while(*chars != '\0')
	{
		if(*chars >= '0' && *chars <= '9')
		{
			value = (*chars - '0') << 4;
		}
		else if(*chars >= 'a' && *chars <= 'f')
		{
			value = (*chars - 'a' + 10) << 4;
		}
		else if(*chars >= 'A' && *chars <= 'F')
		{
			value = (*chars - 'A' + 10) << 4;
		}
		else
		{
			return nil;
		}
		
		chars++;
		
		if(*chars >= '0' && *chars <= '9')
		{
			value |= *chars - '0';
		}
		else if(*chars >= 'a' && *chars <= 'f')
		{
			value |= *chars - 'a' + 10;
		}
		else if(*chars >= 'A' && *chars <= 'F')
		{
			value |= *chars - 'A' + 10;
		}
		else
		{
			return nil;
		}
		
		[data appendBytes: &value length: sizeof(value)];
		
		chars++;
	}
	
	return data;
}

- (NSString *)hexString
{
	NSUInteger dataLength = [self length];
	
	const unsigned char* dataBytes = [self bytes];
	
	NSMutableString* result = [NSMutableString stringWithCapacity: dataLength * 2];
	
	for(NSUInteger i = 0; i < dataLength; i++)
	{
		[result appendFormat: @"%02x", dataBytes[i]];
	}
	
	return result;
}

@end
