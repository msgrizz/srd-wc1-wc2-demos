//
//  BRBluetoothDSPSendMessageLongCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRBluetoothDSPSendMessageLongCommand.h"
#import "BRMessage_Private.h"


@implementation BRBluetoothDSPSendMessageLongCommand

#pragma mark - Public

+ (BRBluetoothDSPSendMessageLongCommand *)commandWithMessageid:(int16_t)messageid parameter:(NSData *)parameter
{
	BRBluetoothDSPSendMessageLongCommand *instance = [[BRBluetoothDSPSendMessageLongCommand alloc] init];
	instance.messageid = messageid;
	instance.parameter = parameter;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_DSP_SEND_MESSAGE_LONG;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"messageid", @"type": @(BRPayloadItemTypeShort)},
			@{@"name": @"parameter", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothDSPSendMessageLongCommand %p> messageid=0x%04X, parameter=%@",
            self, self.messageid, self.parameter];
}

@end
