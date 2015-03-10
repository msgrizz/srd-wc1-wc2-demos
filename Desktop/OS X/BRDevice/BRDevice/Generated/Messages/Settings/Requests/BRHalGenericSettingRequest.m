//
//  BRHalGenericSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRHalGenericSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRHalGenericSettingRequest

#pragma BRSettingRequest

+ (BRHalGenericSettingRequest *)requestWithHalGeneric:(NSData *)halGeneric
{
	BRHalGenericSettingRequest *instance = [[BRHalGenericSettingRequest alloc] init];
	instance.halGeneric = halGeneric;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_GENERIC_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"halGeneric", @"type": @(BRPayloadItemTypeShortArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHalGenericSettingRequest %p> halGeneric=%@",
            self, self.halGeneric];
}

@end
