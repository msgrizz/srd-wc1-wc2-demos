//
//  BRProductNameSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRProductNameSettingResult.h"
#import "BRMessage_Private.h"


@interface BRProductNameSettingResult ()

@property(nonatomic,strong,readwrite) NSString * productName;


@end


@implementation BRProductNameSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_PRODUCT_NAME_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"productName", @"type": @(BRPayloadItemTypeString)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRProductNameSettingResult %p> productName=%@",
            self, self.productName];
}

@end
