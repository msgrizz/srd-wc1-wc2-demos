//
//  BRBluetoothDeletePairingCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRBluetoothDeletePairingCommand.h"
#import "BRMessage_Private.h"


@implementation BRBluetoothDeletePairingCommand

#pragma mark - Public

+ (BRBluetoothDeletePairingCommand *)commandWithConnectionOffset:(uint16_t)connectionOffset
{
	BRBluetoothDeletePairingCommand *instance = [[BRBluetoothDeletePairingCommand alloc] init];
	instance.connectionOffset = connectionOffset;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_DELETE_PAIRING;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionOffset", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothDeletePairingCommand %p> connectionOffset=0x%04X",
            self, self.connectionOffset];
}

@end
