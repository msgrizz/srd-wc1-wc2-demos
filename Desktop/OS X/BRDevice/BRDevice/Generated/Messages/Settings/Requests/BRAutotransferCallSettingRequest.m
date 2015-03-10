//
//  BRAutotransferCallSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAutotransferCallSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRAutotransferCallSettingRequest

#pragma BRSettingRequest

+ (BRAutotransferCallSettingRequest *)request
{
	BRAutotransferCallSettingRequest *instance = [[BRAutotransferCallSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AUTOTRANSFER_CALL_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRAutotransferCallSettingRequest %p>",
            self];
}

@end
