//
//  BRBluetoothConnectionSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRBluetoothConnectionSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRBluetoothConnectionSettingRequest

#pragma BRSettingRequest

+ (BRBluetoothConnectionSettingRequest *)requestWithConnectionOffset:(uint16_t)connectionOffset
{
	BRBluetoothConnectionSettingRequest *instance = [[BRBluetoothConnectionSettingRequest alloc] init];
	instance.connectionOffset = connectionOffset;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_CONNECTION_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRBluetoothConnectionSettingRequest %p> connectionOffset=0x%04X",
            self, self.connectionOffset];
}

@end
