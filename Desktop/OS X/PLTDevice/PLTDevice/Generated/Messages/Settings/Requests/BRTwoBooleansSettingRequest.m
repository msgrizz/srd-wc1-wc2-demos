//
//  BRTwoBooleansSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTwoBooleansSettingRequest.h"
#import "BRMessage_Private.h"




@implementation BRTwoBooleansSettingRequest

#pragma BRSettingRequest

+ (BRTwoBooleansSettingRequest *)request
{
	BRTwoBooleansSettingRequest *instance = [[BRTwoBooleansSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TWO_BOOLEANS_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRTwoBooleansSettingRequest %p>",
            self];
}

@end
