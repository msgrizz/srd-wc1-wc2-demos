//
//  BRBluetoothAddressSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRBluetoothAddressSettingResult.h"
#import "BRMessage_Private.h"


@interface BRBluetoothAddressSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t nap;
@property(nonatomic,assign,readwrite) uint8_t uap;
@property(nonatomic,assign,readwrite) uint32_t lap;


@end


@implementation BRBluetoothAddressSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_ADDRESS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"nap", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"uap", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"lap", @"type": @(BRPayloadItemTypeUnsignedInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothAddressSettingResult %p> nap=0x%04X, uap=0x%02X, lap=0x%08X",
            self, self.nap, self.uap, self.lap];
}

@end
