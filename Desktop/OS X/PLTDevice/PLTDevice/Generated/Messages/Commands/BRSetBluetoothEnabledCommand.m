//
//  BRSetBluetoothEnabledCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetBluetoothEnabledCommand.h"
#import "BRMessage_Private.h"




@implementation BRSetBluetoothEnabledCommand

#pragma mark - Public

+ (BRSetBluetoothEnabledCommand *)commandWithBluetoothEnabled:(BOOL)bluetoothEnabled
{
	BRSetBluetoothEnabledCommand *instance = [[BRSetBluetoothEnabledCommand alloc] init];
	instance.bluetoothEnabled = bluetoothEnabled;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_BLUETOOTH_ENABLED;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"bluetoothEnabled", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetBluetoothEnabledCommand %p> bluetoothEnabled=%@",
            self, (self.bluetoothEnabled ? @"YES" : @"NO")];
}

@end
