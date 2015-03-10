//
//  BRTattooBuildCodeSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTattooBuildCodeSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRTattooBuildCodeSettingRequest

#pragma BRSettingRequest

+ (BRTattooBuildCodeSettingRequest *)request
{
	BRTattooBuildCodeSettingRequest *instance = [[BRTattooBuildCodeSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TATTOO_BUILD_CODE_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRTattooBuildCodeSettingRequest %p>",
            self];
}

@end
