//
//  BRConfigureSecondInboundCallRingTypeCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureSecondInboundCallRingTypeCommand.h"
#import "BRMessage_Private.h"


const uint8_t ConfigureSecondInboundCallRingTypeCommand_RingType_RingTypeNone = 0;
const uint8_t ConfigureSecondInboundCallRingTypeCommand_RingType_RingTypeOnce = 1;
const uint8_t ConfigureSecondInboundCallRingTypeCommand_RingType_RingTypeContinuous = 2;


@implementation BRConfigureSecondInboundCallRingTypeCommand

#pragma mark - Public

+ (BRConfigureSecondInboundCallRingTypeCommand *)commandWithRingType:(uint8_t)ringType
{
	BRConfigureSecondInboundCallRingTypeCommand *instance = [[BRConfigureSecondInboundCallRingTypeCommand alloc] init];
	instance.ringType = ringType;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE;
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
    return [NSString stringWithFormat:@"<BRConfigureSecondInboundCallRingTypeCommand %p> ringType=0x%02X",
            self, self.ringType];
}

@end
