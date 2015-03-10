//
//  BRDisconnectedDeviceEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRDisconnectedDeviceEvent.h"
#import "BRMessage_Private.h"


@interface BRDisconnectedDeviceEvent ()

@property(nonatomic,assign,readwrite) uint8_t address;


@end


@implementation BRDisconnectedDeviceEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DISCONNECTED_DEVICE_EVENT;
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
    return [NSString stringWithFormat:@"<BRDisconnectedDeviceEvent %p> address=0x%02X",
            self, self.address];
}

@end
