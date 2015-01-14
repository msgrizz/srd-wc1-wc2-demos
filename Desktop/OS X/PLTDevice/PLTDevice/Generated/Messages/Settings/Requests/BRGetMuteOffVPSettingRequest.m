//
//  BRGetMuteOffVPSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRGetMuteOffVPSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRGetMuteOffVPSettingRequest

#pragma BRSettingRequest

+ (BRGetMuteOffVPSettingRequest *)request
{
	BRGetMuteOffVPSettingRequest *instance = [[BRGetMuteOffVPSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_MUTE_OFF_VP_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRGetMuteOffVPSettingRequest %p>",
            self];
}

@end
