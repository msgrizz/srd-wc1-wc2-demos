//
//  BRConfigureMuteReminderTimingEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRConfigureMuteReminderTimingEvent.h"
#import "BRMessage_Private.h"


@interface BRConfigureMuteReminderTimingEvent ()

@property(nonatomic,assign,readwrite) uint16_t seconds;


@end


@implementation BRConfigureMuteReminderTimingEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_MUTE_REMINDER_TIMING_EVENT;
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
    return [NSString stringWithFormat:@"<BRConfigureMuteReminderTimingEvent %p> seconds=0x%04X",
            self, self.seconds];
}

@end
