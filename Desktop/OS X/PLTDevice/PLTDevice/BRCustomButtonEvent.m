//
//  BRCustomButtonEvent.m
//  PLTDevice
//
//  Created by Morgan Davis on 8/27/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCustomButtonEvent.h"
#import "BRIncomingMessage_Private.h"


@interface BRCustomButtonEvent ()

@property(nonatomic,assign,readwrite)	uint8_t	index;

@end


@implementation BRCustomButtonEvent

#pragma mark - Public

- (void)parseData
{ //<-- 1007 0000 000A 0802 00
	[super parseData];
	
	uint8_t index;
	[[self.payload subdataWithRange:NSMakeRange(2, sizeof(uint8_t))] getBytes:&index length:sizeof(uint8_t)];
	self.index = index;
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<BRCustomButtonEvent %p> index=%d",
			self, self.index];
}

@end
