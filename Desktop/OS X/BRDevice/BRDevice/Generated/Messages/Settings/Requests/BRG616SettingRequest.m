//
//  BRG616SettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRG616SettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRG616SettingRequest

#pragma BRSettingRequest

+ (BRG616SettingRequest *)request
{
	BRG616SettingRequest *instance = [[BRG616SettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_G616_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRG616SettingRequest %p>",
            self];
}

@end
