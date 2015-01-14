//
//  BRVoiceSilentDetectionSettingChangedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRVoiceSilentDetectionSettingChangedEvent.h"
#import "BRMessage_Private.h"


@interface BRVoiceSilentDetectionSettingChangedEvent ()

@property(nonatomic,assign,readwrite) uint8_t mode;


@end


@implementation BRVoiceSilentDetectionSettingChangedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOICE_SILENT_DETECTION_SETTING_CHANGED_EVENT;
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
    return [NSString stringWithFormat:@"<BRVoiceSilentDetectionSettingChangedEvent %p> mode=0x%02X",
            self, self.mode];
}

@end
