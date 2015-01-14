//
//  BRLyncDialToneOnCallPressSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRLyncDialToneOnCallPressSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRLyncDialToneOnCallPressSettingRequest

#pragma BRSettingRequest

+ (BRLyncDialToneOnCallPressSettingRequest *)request
{
	BRLyncDialToneOnCallPressSettingRequest *instance = [[BRLyncDialToneOnCallPressSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRLyncDialToneOnCallPressSettingRequest %p>",
            self];
}

@end
