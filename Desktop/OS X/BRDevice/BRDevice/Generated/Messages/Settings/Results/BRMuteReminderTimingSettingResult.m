//
//  BRMuteReminderTimingSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRMuteReminderTimingSettingResult.h"
#import "BRMessage_Private.h"


@interface BRMuteReminderTimingSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t seconds;


@end


@implementation BRMuteReminderTimingSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MUTE_REMINDER_TIMING_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"seconds", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRMuteReminderTimingSettingResult %p> seconds=0x%04X",
            self, self.seconds];
}

@end
