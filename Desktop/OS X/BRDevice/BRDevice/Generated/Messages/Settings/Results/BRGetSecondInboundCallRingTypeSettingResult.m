//
//  BRGetSecondInboundCallRingTypeSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRGetSecondInboundCallRingTypeSettingResult.h"
#import "BRMessage_Private.h"


@interface BRGetSecondInboundCallRingTypeSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t ringType;


@end


@implementation BRGetSecondInboundCallRingTypeSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"ringType", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRGetSecondInboundCallRingTypeSettingResult %p> ringType=0x%02X",
            self, self.ringType];
}

@end
