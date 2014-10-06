//
//  BRSubscribedServiceDataEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSubscribedServiceDataEvent.h"
#import "BRMessage_Private.h"




@interface BRSubscribedServiceDataEvent ()

@property(nonatomic,assign,readwrite) uint16_t serviceID;
@property(nonatomic,assign,readwrite) uint16_t characteristic;
@property(nonatomic,strong,readwrite) NSData * serviceData;


@end


@implementation BRSubscribedServiceDataEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SUBSCRIBED_SERVICE_DATA_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serviceID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"serviceData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSubscribedServiceDataEvent %p> serviceID=0x%04X, characteristic=0x%04X, serviceData=%@",
            self, self.serviceID, self.characteristic, self.serviceData];
}

@end
