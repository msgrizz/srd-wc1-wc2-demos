//
//  BRProductNameSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 5/28/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRProductNameSettingResponse.h"
#import "BRIncomingMessage_Private.h"


@interface BRProductNameSettingResponse ()

@property(nonatomic,strong,readwrite) NSString   *name;

@end


@implementation BRProductNameSettingResponse

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
	uint16_t len = 0;
	[[self.payload subdataWithRange:NSMakeRange(2, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
	len = ntohs(len);
	
	NSData *nameData = [self.payload subdataWithRange:NSMakeRange(4, len*2)];
	
	self.name = [[NSString alloc] initWithData:nameData encoding:NSUTF16StringEncoding];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRProductNameSettingResponse %p> name=%@",
            self, self.name];
}

@end
