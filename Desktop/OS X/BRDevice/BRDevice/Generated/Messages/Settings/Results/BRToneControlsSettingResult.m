//
//  BRToneControlsSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRToneControlsSettingResult.h"
#import "BRMessage_Private.h"


@interface BRToneControlsSettingResult ()

@property(nonatomic,strong,readwrite) NSData * toneLevels;


@end


@implementation BRToneControlsSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TONE_CONTROLS_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"toneLevels", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRToneControlsSettingResult %p> toneLevels=%@",
            self, self.toneLevels];
}

@end
