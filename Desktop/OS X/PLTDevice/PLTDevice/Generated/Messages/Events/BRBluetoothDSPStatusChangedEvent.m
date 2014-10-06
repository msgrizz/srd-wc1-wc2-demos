//
//  BRBluetoothDSPStatusChangedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRBluetoothDSPStatusChangedEvent.h"
#import "BRMessage_Private.h"




@interface BRBluetoothDSPStatusChangedEvent ()

@property(nonatomic,assign,readwrite) int16_t messageid;
@property(nonatomic,assign,readwrite) int16_t parametera;
@property(nonatomic,assign,readwrite) int16_t parameterb;
@property(nonatomic,assign,readwrite) int16_t parameterc;
@property(nonatomic,assign,readwrite) int16_t parameterd;


@end


@implementation BRBluetoothDSPStatusChangedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_DSP_STATUS_CHANGED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"messageid", @"type": @(BRPayloadItemTypeShort)},
			@{@"name": @"parametera", @"type": @(BRPayloadItemTypeShort)},
			@{@"name": @"parameterb", @"type": @(BRPayloadItemTypeShort)},
			@{@"name": @"parameterc", @"type": @(BRPayloadItemTypeShort)},
			@{@"name": @"parameterd", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothDSPStatusChangedEvent %p> messageid=0x%04X, parametera=0x%04X, parameterb=0x%04X, parameterc=0x%04X, parameterd=0x%04X",
            self, self.messageid, self.parametera, self.parameterb, self.parameterc, self.parameterd];
}

@end
