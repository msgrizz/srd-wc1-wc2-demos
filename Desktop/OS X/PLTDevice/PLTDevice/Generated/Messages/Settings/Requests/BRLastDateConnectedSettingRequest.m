//
//  BRLastDateConnectedSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRLastDateConnectedSettingRequest.h"
#import "BRMessage_Private.h"




@implementation BRLastDateConnectedSettingRequest

#pragma BRSettingRequest

+ (BRLastDateConnectedSettingRequest *)request
{
	BRLastDateConnectedSettingRequest *instance = [[BRLastDateConnectedSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_LAST_DATE_CONNECTED_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRLastDateConnectedSettingRequest %p>",
            self];
}

@end
