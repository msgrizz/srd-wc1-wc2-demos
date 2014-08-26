//
//  BRConnectionStatusSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 7/17/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConnectionStatusSettingResponse.h"
#import "BRIncomingMessage_Private.h"


@interface BRConnectionStatusSettingResponse ()

@property(nonatomic,strong,readwrite) NSMutableArray   *downstreamPortIDs;
@property(nonatomic,strong,readwrite) NSMutableArray   *connectedPortIDs;
@property(nonatomic,assign,readwrite) uint8_t			originatingPortID;

@end


@implementation BRConnectionStatusSettingResponse

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
	self.downstreamPortIDs = [NSMutableArray array];
	self.connectedPortIDs = [NSMutableArray array];
	self.originatingPortID = 0;
	
	enum DeviceInfo {
		ConnectionStatusDownstreamPortIDs = 0,
		ConnectionStatusConnectedPortIDs
	};
	
    uint16_t offset = 2;
	uint16_t len = 0;
	uint8_t *vers;
	
	for (enum DeviceInfo i = ConnectionStatusDownstreamPortIDs; i <= ConnectionStatusConnectedPortIDs; i++) {
		
		[[self.payload subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
		len = ntohs(len);
		
		offset += sizeof(uint16_t);
		
		vers = malloc(len);
		[[self.payload subdataWithRange:NSMakeRange(offset, len)] getBytes:vers length:len];
		
		for (int v=0; v<len; v++) {
			uint8_t version = vers[v];
			switch (i) {
				case ConnectionStatusDownstreamPortIDs:
					[(NSMutableArray *)self.downstreamPortIDs addObject:@(version)];
					break;
				case ConnectionStatusConnectedPortIDs:
					[(NSMutableArray *)self.connectedPortIDs addObject:@(version)];
					break;
			}
		}
		
		free(vers);
		
		offset += len;
	}
	
	uint8_t originatingPort;
	[[self.payload subdataWithRange:NSMakeRange(offset, sizeof(uint8_t))] getBytes:&originatingPort length:sizeof(uint8_t)];
	self.originatingPortID = originatingPort;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConnectionStatusSettingResponse %p> downstreamPortIDs=%@, connectedPortIDs=%@, originatingPortID=%d",
            self, self.downstreamPortIDs, self.connectedPortIDs, self.originatingPortID];
}

@end
