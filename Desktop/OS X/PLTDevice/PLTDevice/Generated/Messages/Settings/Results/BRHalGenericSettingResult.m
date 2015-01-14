//
//  BRHalGenericSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHalGenericSettingResult.h"
#import "BRMessage_Private.h"


@interface BRHalGenericSettingResult ()

@property(nonatomic,strong,readwrite) NSData * halGeneric;


@end


@implementation BRHalGenericSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HAL_GENERIC_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRHalGenericSettingResult %p> halGeneric=%@",
            self, self.halGeneric];
}

@end
