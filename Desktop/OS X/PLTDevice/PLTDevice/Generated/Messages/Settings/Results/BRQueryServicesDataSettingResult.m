//
//  BRQueryServicesDataSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRQueryServicesDataSettingResult.h"
#import "BRMessage_Private.h"


@interface BRQueryServicesDataSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t serviceID;
@property(nonatomic,assign,readwrite) uint16_t characteristic;
@property(nonatomic,strong,readwrite) NSData * servicedata;


@end


@implementation BRQueryServicesDataSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_QUERY_SERVICES_DATA_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serviceID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"servicedata", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRQueryServicesDataSettingResult %p> serviceID=0x%04X, characteristic=0x%04X, servicedata=%@",
            self, self.serviceID, self.characteristic, self.servicedata];
}

@end
