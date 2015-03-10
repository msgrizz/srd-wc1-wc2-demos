//
//  BRVoiceSilentDetectionSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRVoiceSilentDetectionSettingResult.h"
#import "BRMessage_Private.h"


@interface BRVoiceSilentDetectionSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t mode;


@end


@implementation BRVoiceSilentDetectionSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_VOICE_SILENT_DETECTION_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRVoiceSilentDetectionSettingResult %p> mode=0x%02X",
            self, self.mode];
}

@end
