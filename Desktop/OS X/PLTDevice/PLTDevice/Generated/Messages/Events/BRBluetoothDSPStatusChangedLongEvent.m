//
//  BRBluetoothDSPStatusChangedLongEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRBluetoothDSPStatusChangedLongEvent.h"
#import "BRMessage_Private.h"


@interface BRBluetoothDSPStatusChangedLongEvent ()

@property(nonatomic,assign,readwrite) int16_t keyAddr;
@property(nonatomic,strong,readwrite) NSData * keyParameter;


@end


@implementation BRBluetoothDSPStatusChangedLongEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_DSP_STATUS_CHANGED_LONG_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"keyAddr", @"type": @(BRPayloadItemTypeShort)},
			@{@"name": @"keyParameter", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothDSPStatusChangedLongEvent %p> keyAddr=0x%04X, keyParameter=%@",
            self, self.keyAddr, self.keyParameter];
}

@end
