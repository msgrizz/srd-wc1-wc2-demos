//
//  BRUSBPIDSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRUSBPIDSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRUSBPIDSettingRequest

#pragma BRSettingRequest

+ (BRUSBPIDSettingRequest *)request
{
	BRUSBPIDSettingRequest *instance = [[BRUSBPIDSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_USB_PID_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRUSBPIDSettingRequest %p>",
            self];
}

@end
