//
//  BRDeckardVersionSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRDeckardVersionSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRDeckardVersionSettingRequest

#pragma BRSettingRequest

+ (BRDeckardVersionSettingRequest *)request
{
	BRDeckardVersionSettingRequest *instance = [[BRDeckardVersionSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_DECKARD_VERSION_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRDeckardVersionSettingRequest %p>",
            self];
}

@end
