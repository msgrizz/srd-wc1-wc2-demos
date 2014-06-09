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
#import "NSData+HexStrings.h"


@implementation BROutgoingMessage

@dynamic data;

- (NSData *)data
{
	NSString *hexString = [NSString stringWithFormat:@"1 %03X %@ %1X",
						   self.length,		// length
						   self.address,	// address
						   self.type		// type
						   ];	
	NSMutableData *data = [[NSData dataWithHexString:hexString] mutableCopy];
	[data appendData:self.payload];
	return data;
}

#pragma mark - Public

//- (id)init
//{
//	self = [super init];
//	self.address = @"0000000";
//	return self;
//}

@end
