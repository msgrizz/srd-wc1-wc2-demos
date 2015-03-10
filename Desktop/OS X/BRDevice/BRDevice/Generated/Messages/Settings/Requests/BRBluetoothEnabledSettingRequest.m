//
//  BRBluetoothEnabledSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRBluetoothEnabledSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRBluetoothEnabledSettingRequest

#pragma BRSettingRequest

+ (BRBluetoothEnabledSettingRequest *)request
{
	BRBluetoothEnabledSettingRequest *instance = [[BRBluetoothEnabledSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_ENABLED_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[

			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothEnabledSettingRequest %p>",
            self];
}

@end
