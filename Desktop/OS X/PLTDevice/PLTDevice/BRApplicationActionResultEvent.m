//
//  BRApplicationActionResultEvent.m
//  PLTDevice
//
//  Created by Morgan Davis on 6/4/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRApplicationActionResultEvent.h"
#import "BRIncomingMessage_Private.h"


@interface BRApplicationActionResultEvent ()

@property(nonatomic,assign,readwrite)	uint16_t	applicationID;
@property(nonatomic,assign,readwrite)	uint16_t	action;
@property(nonatomic,strong,readwrite)	NSData		*operatingData;
@property(nonatomic,strong,readwrite)	NSData		*resultData;

@end


@implementation BRApplicationActionResultEvent

#pragma mark - Public

- (void)parseData
{ //<-- 100C 0500 000A FF1E 0002 0002 0009
	[super parseData];
	
	uint16_t offset = 8;
	
	uint16_t applicationID;
	[[self.data subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))] getBytes:&applicationID length:sizeof(uint16_t)];
	applicationID = ntohs(applicationID);
	self.applicationID = applicationID;
	
	offset += 2;
	
	uint16_t action;
	[[self.data subdataWithRange:NSMakeRange(offset, sizeof(action))] getBytes:&action length:sizeof(action)];
	action = ntohs(action);
	self.action = action;
	
	offset += 2;
	
	// <-- 100F 0500 000A FF1E 0002 0004 0000 0200 02
	if (action == 4) { // special case for now until MindTree fixes the Deckard format
		offset += 1; // skip "result code" byte
		uint16_t len;
		[[self.data subdataWithRange:NSMakeRange(offset + 1, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
		//len = ntohs(len);
		self.resultData = [self.data subdataWithRange:NSMakeRange(offset, len)];
	}
	else {
		self.resultData = [self.data subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))];
	}
	
//	offset += 2;
//	offset += len;
//	
//	[[self.data subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
//	len = ntohl(len);
//	self.resultData = [self.data subdataWithRange:NSMakeRange(offset + len, len)];
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<BRApplicationActionResultEvent %p> applicationID=%04X, action=%04X, operatingData=%@, resultData=%@",
			self, self.applicationID, self.action, self.operatingData, self.resultData];
}

@end
