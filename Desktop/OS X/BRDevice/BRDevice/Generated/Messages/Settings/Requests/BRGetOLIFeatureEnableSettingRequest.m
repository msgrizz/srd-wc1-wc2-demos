//
//  BRGetOLIFeatureEnableSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRGetOLIFeatureEnableSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRGetOLIFeatureEnableSettingRequest

#pragma BRSettingRequest

+ (BRGetOLIFeatureEnableSettingRequest *)request
{
	BRGetOLIFeatureEnableSettingRequest *instance = [[BRGetOLIFeatureEnableSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_OLI_FEATURE_ENABLE_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[

			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetOLIFeatureEnableSettingRequest %p>",
            self];
}

@end
