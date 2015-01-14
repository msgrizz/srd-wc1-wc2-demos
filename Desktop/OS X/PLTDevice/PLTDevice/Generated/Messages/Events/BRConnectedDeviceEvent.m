//
//  BRConnectedDeviceEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConnectedDeviceEvent.h"
#import "BRMessage_Private.h"


@interface BRConnectedDeviceEvent ()

@property(nonatomic,assign,readwrite) uint8_t address;


@end


@implementation BRConnectedDeviceEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONNECTED_DEVICE_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"address", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConnectedDeviceEvent %p> address=0x%02X",
            self, self.address];
}

@end
