//
//  BRGetOLIFeatureEnableSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGetOLIFeatureEnableSettingResult.h"
#import "BRMessage_Private.h"


@interface BRGetOLIFeatureEnableSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t oLIenable;


@end


@implementation BRGetOLIFeatureEnableSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_OLI_FEATURE_ENABLE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"oLIenable", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetOLIFeatureEnableSettingResult %p> oLIenable=0x%02X",
            self, self.oLIenable];
}

@end
