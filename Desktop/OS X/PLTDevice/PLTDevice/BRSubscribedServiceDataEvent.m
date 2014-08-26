//
//  BRSubscribedServiceDataEvent.m
//  PLTDevice
//
//  Created by Morgan Davis on 6/20/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSubscribedServiceDataEvent.h"
#import "NSData+HexStrings.h"
#import "BRIncomingMessage_Private.h"


@interface BRSubscribedServiceDataEvent ()

@property(nonatomic,assign,readwrite)	uint16_t	serviceID;
@property(nonatomic,assign,readwrite)	uint16_t	characteristic;
@property(nonatomic,strong,readwrite)	NSData		*serviceData;

@end


@implementation BRSubscribedServiceDataEvent

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
	uint16_t serviceID;
	uint16_t characteristic;
	uint16_t len;
	
	uint16_t offset = 2;
	
	[[self.payload subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))] getBytes:&serviceID length:sizeof(uint16_t)];
	self.serviceID = ntohs(serviceID);
	offset += sizeof(uint16_t);
	
	[[self.payload subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))] getBytes:&characteristic length:sizeof(uint16_t)];
	self.characteristic = ntohs(characteristic);
	offset += sizeof(uint16_t);
	
	[[self.payload subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
	len = ntohs(len);
	offset += sizeof(uint16_t);
	
#warning TEMP FOR INVALID MESSAGE FORMAT
	if (self.serviceID == 0x000D || self.serviceID == 0x0008 || self.serviceID == 0x000F) { // skin temp/humidity/pressure
		len = 2;
	}
	
	self.serviceData = [self.payload subdataWithRange:NSMakeRange(offset, len)];
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<BRSubscribedServiceDataEvent %p> serviceID: 0x%04X, characteristic: 0xpo serv%04X, serviceData=%@",
			self, self.serviceID, self.characteristic, [self.serviceData hexStringWithSpaceEvery:2]];
}

@end
