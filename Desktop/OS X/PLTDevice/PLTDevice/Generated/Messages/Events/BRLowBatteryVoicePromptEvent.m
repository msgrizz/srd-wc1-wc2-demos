//
//  BRLowBatteryVoicePromptEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRLowBatteryVoicePromptEvent.h"
#import "BRMessage_Private.h"




@interface BRLowBatteryVoicePromptEvent ()

@property(nonatomic,assign,readwrite) uint8_t urgency;


@end


@implementation BRLowBatteryVoicePromptEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_LOW_BATTERY_VOICE_PROMPT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"urgency", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRLowBatteryVoicePromptEvent %p> urgency=0x%02X",
            self, self.urgency];
}

@end
