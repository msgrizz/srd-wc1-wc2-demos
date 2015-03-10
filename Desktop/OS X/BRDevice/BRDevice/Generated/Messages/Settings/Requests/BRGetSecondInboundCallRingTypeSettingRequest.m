//
//  BRGetSecondInboundCallRingTypeSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRGetSecondInboundCallRingTypeSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRGetSecondInboundCallRingTypeSettingRequest

#pragma BRSettingRequest

+ (BRGetSecondInboundCallRingTypeSettingRequest *)request
{
	BRGetSecondInboundCallRingTypeSettingRequest *instance = [[BRGetSecondInboundCallRingTypeSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRGetSecondInboundCallRingTypeSettingRequest %p>",
            self];
}

@end
