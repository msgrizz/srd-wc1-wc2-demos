//
//  NSData+Hash.m
//  Shaaaaa
//
//  Created by Morgan Davis on 6/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "NSData+Hash.h"
//#import "NSData+HexString.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSData (Hash)

- (NSData *)MD5Data
{
	unsigned char hashBytes[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5((const unsigned char*)[self bytes], (CC_LONG)[self length], (unsigned char*)hashBytes);
	
	return [NSData dataWithBytes: hashBytes length: CC_MD5_DIGEST_LENGTH];
}

//- (NSString *)MD5HexString
//{
//	return [[self MD5Data] hexString];
//}

- (NSData *)SHA1Data
{
	unsigned char hashBytes[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1((const unsigned char*)[self bytes], (CC_LONG)[self length], (unsigned char*)hashBytes);
	
	return [NSData dataWithBytes: hashBytes length: CC_SHA1_DIGEST_LENGTH];
}

//- (NSString *)SHA1HexString
//{
//	return [[self SHA1Data] hexString];
//}

@end
