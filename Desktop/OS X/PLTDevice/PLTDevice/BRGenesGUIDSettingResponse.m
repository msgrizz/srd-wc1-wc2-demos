//
//  BRGenesGUIDSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 5/28/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGenesGUIDSettingResponse.h"
#import "BRIncomingMessage_Private.h"


@interface BRGenesGUIDSettingResponse ()

@property(nonatomic,strong,readwrite) NSData   *guidData;

@end


@implementation BRGenesGUIDSettingResponse

#pragma mark - Public

- (void)parseData
{
	[super parseData];

	uint16_t len = 0;
	[[self.payload subdataWithRange:NSMakeRange(2, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
	len = ntohs(len);

	self.guidData = [self.payload subdataWithRange:NSMakeRange(4, len)];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGenesGUIDSettingResponse %p> guidData=%@",
            self, self.guidData];
}

@end
