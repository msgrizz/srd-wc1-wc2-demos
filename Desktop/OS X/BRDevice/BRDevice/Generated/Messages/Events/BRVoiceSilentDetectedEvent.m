//
//  BRVoiceSilentDetectedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRVoiceSilentDetectedEvent.h"
#import "BRMessage_Private.h"


@interface BRVoiceSilentDetectedEvent ()

@property(nonatomic,assign,readwrite) uint8_t mode;


@end


@implementation BRVoiceSilentDetectedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOICE_SILENT_DETECTED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"mode", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRVoiceSilentDetectedEvent %p> mode=0x%02X",
            self, self.mode];
}

@end
