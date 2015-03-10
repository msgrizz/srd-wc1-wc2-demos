//
//  BRBluetoothAddPairingCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRBluetoothAddPairingCommand.h"
#import "BRMessage_Private.h"


@implementation BRBluetoothAddPairingCommand

#pragma mark - Public

+ (BRBluetoothAddPairingCommand *)commandWithConnectionOffset:(uint16_t)connectionOffset persist:(BOOL)persist nap:(uint16_t)nap uap:(uint8_t)uap lap:(uint32_t)lap linkKeyType:(uint16_t)linkKeyType linkKey:(NSData *)linkKey
{
	BRBluetoothAddPairingCommand *instance = [[BRBluetoothAddPairingCommand alloc] init];
	instance.connectionOffset = connectionOffset;
	instance.persist = persist;
	instance.nap = nap;
	instance.uap = uap;
	instance.lap = lap;
	instance.linkKeyType = linkKeyType;
	instance.linkKey = linkKey;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_ADD_PAIRING;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionOffset", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"persist", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"nap", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"uap", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"lap", @"type": @(BRPayloadItemTypeUnsignedInt)},
			@{@"name": @"linkKeyType", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"linkKey", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothAddPairingCommand %p> connectionOffset=0x%04X, persist=%@, nap=0x%04X, uap=0x%02X, lap=0x%08X, linkKeyType=0x%04X, linkKey=%@",
            self, self.connectionOffset, (self.persist ? @"YES" : @"NO"), self.nap, self.uap, self.lap, self.linkKeyType, self.linkKey];
}

@end
