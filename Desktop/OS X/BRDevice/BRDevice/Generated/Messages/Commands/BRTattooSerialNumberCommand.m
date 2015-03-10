//
//  BRTattooSerialNumberCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTattooSerialNumberCommand.h"
#import "BRMessage_Private.h"


@implementation BRTattooSerialNumberCommand

#pragma mark - Public

+ (BRTattooSerialNumberCommand *)commandWithSerialNumber:(NSData *)serialNumber
{
	BRTattooSerialNumberCommand *instance = [[BRTattooSerialNumberCommand alloc] init];
	instance.serialNumber = serialNumber;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TATTOO_SERIAL_NUMBER;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serialNumber", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTattooSerialNumberCommand %p> serialNumber=%@",
            self, self.serialNumber];
}

@end
