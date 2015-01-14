//
//  BRBluetoothDSPSendMessageCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRBluetoothDSPSendMessageCommand.h"
#import "BRMessage_Private.h"


@implementation BRBluetoothDSPSendMessageCommand

#pragma mark - Public

+ (BRBluetoothDSPSendMessageCommand *)commandWithMessageid:(int16_t)messageid parametera:(int16_t)parametera parameterb:(int16_t)parameterb parameterc:(int16_t)parameterc parameterd:(int16_t)parameterd
{
	BRBluetoothDSPSendMessageCommand *instance = [[BRBluetoothDSPSendMessageCommand alloc] init];
	instance.messageid = messageid;
	instance.parametera = parametera;
	instance.parameterb = parameterb;
	instance.parameterc = parameterc;
	instance.parameterd = parameterd;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_DSP_SEND_MESSAGE;
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
    return [NSString stringWithFormat:@"<BRBluetoothDSPSendMessageCommand %p> messageid=0x%04X, parametera=0x%04X, parameterb=0x%04X, parameterc=0x%04X, parameterd=0x%04X",
            self, self.messageid, self.parametera, self.parameterb, self.parameterc, self.parameterd];
}

@end
