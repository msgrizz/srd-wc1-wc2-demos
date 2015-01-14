//
//  BRSubscribeToServicesEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSubscribeToServicesEvent.h"
#import "BRMessage_Private.h"


@interface BRSubscribeToServicesEvent ()

@property(nonatomic,assign,readwrite) uint16_t serviceID;
@property(nonatomic,assign,readwrite) uint16_t characteristic;
@property(nonatomic,assign,readwrite) uint16_t mode;
@property(nonatomic,assign,readwrite) uint16_t period;


@end


@implementation BRSubscribeToServicesEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SUBSCRIBE_TO_SERVICES_EVENT;
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
    return [NSString stringWithFormat:@"<BRSubscribeToServicesEvent %p> serviceID=0x%04X, characteristic=0x%04X, mode=0x%04X, period=0x%04X",
            self, self.serviceID, self.characteristic, self.mode, self.period];
}

@end
