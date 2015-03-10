//
//  BRSubscribeToServicesCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSubscribeToServicesCommand.h"
#import "BRMessage_Private.h"


@implementation BRSubscribeToServicesCommand

#pragma mark - Public

+ (BRSubscribeToServicesCommand *)commandWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic mode:(uint16_t)mode period:(uint16_t)period
{
	BRSubscribeToServicesCommand *instance = [[BRSubscribeToServicesCommand alloc] init];
	instance.serviceID = serviceID;
	instance.characteristic = characteristic;
	instance.mode = mode;
	instance.period = period;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SUBSCRIBE_TO_SERVICES;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serviceID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"mode", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"period", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSubscribeToServicesCommand %p> serviceID=0x%04X, characteristic=0x%04X, mode=0x%04X, period=0x%04X",
            self, self.serviceID, self.characteristic, self.mode, self.period];
}

@end
