//
//  BRConfigureSecondInboundCallRingTypeEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureSecondInboundCallRingTypeEvent.h"
#import "BRMessage_Private.h"


@interface BRConfigureSecondInboundCallRingTypeEvent ()

@property(nonatomic,assign,readwrite) uint8_t ringType;


@end


@implementation BRConfigureSecondInboundCallRingTypeEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_EVENT;
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
    return [NSString stringWithFormat:@"<BRConfigureSecondInboundCallRingTypeEvent %p> ringType=0x%02X",
            self, self.ringType];
}

@end
