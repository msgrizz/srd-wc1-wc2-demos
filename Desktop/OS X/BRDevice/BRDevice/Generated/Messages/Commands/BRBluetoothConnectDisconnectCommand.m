//
//  BRBluetoothConnectDisconnectCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRBluetoothConnectDisconnectCommand.h"
#import "BRMessage_Private.h"


@implementation BRBluetoothConnectDisconnectCommand

#pragma mark - Public

+ (BRBluetoothConnectDisconnectCommand *)commandWithConnectionOffset:(uint16_t)connectionOffset disconnect:(BOOL)disconnect
{
	BRBluetoothConnectDisconnectCommand *instance = [[BRBluetoothConnectDisconnectCommand alloc] init];
	instance.connectionOffset = connectionOffset;
	instance.disconnect = disconnect;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_CONNECT_DISCONNECT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionOffset", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"disconnect", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothConnectDisconnectCommand %p> connectionOffset=0x%04X, disconnect=%@",
            self, self.connectionOffset, (self.disconnect ? @"YES" : @"NO")];
}

@end
