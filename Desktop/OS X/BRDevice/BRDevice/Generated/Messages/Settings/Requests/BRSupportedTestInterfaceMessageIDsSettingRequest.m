//
//  BRSupportedTestInterfaceMessageIDsSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSupportedTestInterfaceMessageIDsSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRSupportedTestInterfaceMessageIDsSettingRequest

#pragma BRSettingRequest

+ (BRSupportedTestInterfaceMessageIDsSettingRequest *)request
{
	BRSupportedTestInterfaceMessageIDsSettingRequest *instance = [[BRSupportedTestInterfaceMessageIDsSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SUPPORTED_TEST_INTERFACE_MESSAGE_IDS_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRSupportedTestInterfaceMessageIDsSettingRequest %p>",
            self];
}

@end
