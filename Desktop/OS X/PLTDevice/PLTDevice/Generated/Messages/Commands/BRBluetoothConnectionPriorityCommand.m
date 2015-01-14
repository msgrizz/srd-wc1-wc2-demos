//
//  BRBluetoothConnectionPriorityCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRBluetoothConnectionPriorityCommand.h"
#import "BRMessage_Private.h"


@implementation BRBluetoothConnectionPriorityCommand

#pragma mark - Public

+ (BRBluetoothConnectionPriorityCommand *)commandWithConnectionOffset:(uint16_t)connectionOffset allowSmartDisconnect:(BOOL)allowSmartDisconnect
{
	BRBluetoothConnectionPriorityCommand *instance = [[BRBluetoothConnectionPriorityCommand alloc] init];
	instance.connectionOffset = connectionOffset;
	instance.allowSmartDisconnect = allowSmartDisconnect;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_CONNECTION_PRIORITY;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"connectionOffset", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"allowSmartDisconnect", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothConnectionPriorityCommand %p> connectionOffset=0x%04X, allowSmartDisconnect=%@",
            self, self.connectionOffset, (self.allowSmartDisconnect ? @"YES" : @"NO")];
}

@end
