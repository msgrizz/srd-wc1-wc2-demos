//
//  BRBluetoothConnectionEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRBluetoothConnectionEvent.h"
#import "BRMessage_Private.h"


@interface BRBluetoothConnectionEvent ()

@property(nonatomic,assign,readwrite) uint16_t connectionOffset;
@property(nonatomic,assign,readwrite) uint16_t nap;
@property(nonatomic,assign,readwrite) uint8_t uap;
@property(nonatomic,assign,readwrite) uint32_t lap;
@property(nonatomic,assign,readwrite) uint8_t priority;
@property(nonatomic,strong,readwrite) NSString * productname;


@end


@implementation BRBluetoothConnectionEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_CONNECTION_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionOffset", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"nap", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"uap", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"lap", @"type": @(BRPayloadItemTypeUnsignedInt)},
			@{@"name": @"priority", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"productname", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothConnectionEvent %p> connectionOffset=0x%04X, nap=0x%04X, uap=0x%02X, lap=0x%08X, priority=0x%02X, productname=%@",
            self, self.connectionOffset, self.nap, self.uap, self.lap, self.priority, self.productname];
}

@end
