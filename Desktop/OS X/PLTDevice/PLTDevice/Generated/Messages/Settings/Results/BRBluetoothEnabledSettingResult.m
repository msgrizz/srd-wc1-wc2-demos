//
//  BRBluetoothEnabledSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRBluetoothEnabledSettingResult.h"
#import "BRMessage_Private.h"


@interface BRBluetoothEnabledSettingResult ()

@property(nonatomic,assign,readwrite) BOOL bluetoothEnabled;


@end


@implementation BRBluetoothEnabledSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_ENABLED_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRBluetoothEnabledSettingResult %p> bluetoothEnabled=%@",
            self, (self.bluetoothEnabled ? @"YES" : @"NO")];
}

@end
