//
//  BRConfigureServicesCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRConfigureServicesCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureServicesCommand

#pragma mark - Public

+ (BRConfigureServicesCommand *)commandWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic configurationData:(NSData *)configurationData
{
	BRConfigureServicesCommand *instance = [[BRConfigureServicesCommand alloc] init];
	instance.serviceID = serviceID;
	instance.characteristic = characteristic;
	instance.configurationData = configurationData;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_SERVICES;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serviceID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"configurationData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureServicesCommand %p> serviceID=0x%04X, characteristic=0x%04X, configurationData=%@",
            self, self.serviceID, self.characteristic, self.configurationData];
}

@end
