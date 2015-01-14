//
//  BRTombstoneSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTombstoneSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRTombstoneSettingRequest

#pragma BRSettingRequest

+ (BRTombstoneSettingRequest *)request
{
	BRTombstoneSettingRequest *instance = [[BRTombstoneSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TOMBSTONE_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRTombstoneSettingRequest %p>",
            self];
}

@end
