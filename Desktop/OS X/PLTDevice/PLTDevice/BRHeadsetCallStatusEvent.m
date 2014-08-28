//
//  BRHeadsetCallStatusEvent
//  PLTDevice
//
//  Created by Morgan Davis on 8/27/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHeadsetCallStatusEvent.h"
#import "BRIncomingMessage_Private.h"


@interface BRHeadsetCallStatusEvent ()

@property(nonatomic,assign,readwrite)	uint16_t	numberOfDevices;
@property(nonatomic,assign,readwrite)	uint8_t		connectionID;
@property(nonatomic,assign,readwrite)	uint8_t		state;
@property(nonatomic,strong,readwrite)	NSString	*number;

@end


@implementation BRHeadsetCallStatusEvent

#pragma mark - Public

- (void)parseData
{ // <-- 1020 0000 000A 0E22 0001 0202 000A 0038 0033 0031 0034 0031 0039 0038 0036 0035 0031 
	[super parseData];
	
	uint16_t numberOfDevices;
	[[self.payload subdataWithRange:NSMakeRange(2, sizeof(uint16_t))] getBytes:&numberOfDevices length:sizeof(uint16_t)];
	self.numberOfDevices = ntohs(numberOfDevices);
	
	uint8_t connectionID;
	[[self.payload subdataWithRange:NSMakeRange(4, sizeof(uint8_t))] getBytes:&connectionID length:sizeof(uint8_t)];
	self.connectionID = connectionID;
	
	uint8_t state;
	[[self.payload subdataWithRange:NSMakeRange(5, sizeof(uint8_t))] getBytes:&state length:sizeof(uint8_t)];
	self.state = state;
	
	NSData *numberData = [self.payload subdataWithRange:NSMakeRange(6, [self.payload length] - 6)];
	NSString *number = [[NSString alloc] initWithData:numberData encoding:NSUTF16StringEncoding]; // UCS-2 encoding...
	self.number = [number stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<BRHeadsetCallStatusEvent %p> numberOfDevices=%d, connectionID=%d, state=%d, number=%@",
			self, self.numberOfDevices, self.connectionID, self.state, self.number];
}

@end
