//
//  BRFirmwareVersionSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRFirmwareVersionSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRFirmwareVersionSettingRequest

#pragma BRSettingRequest

+ (BRFirmwareVersionSettingRequest *)request
{
	BRFirmwareVersionSettingRequest *instance = [[BRFirmwareVersionSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FIRMWARE_VERSION_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRFirmwareVersionSettingRequest %p>",
            self];
}

@end
