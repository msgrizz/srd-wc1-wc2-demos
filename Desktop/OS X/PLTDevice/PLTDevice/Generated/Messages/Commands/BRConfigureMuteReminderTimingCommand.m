//
//  BRConfigureMuteReminderTimingCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureMuteReminderTimingCommand.h"
#import "BRMessage_Private.h"




@implementation BRConfigureMuteReminderTimingCommand

#pragma mark - Public

+ (BRConfigureMuteReminderTimingCommand *)commandWithSeconds:(uint16_t)seconds
{
	BRConfigureMuteReminderTimingCommand *instance = [[BRConfigureMuteReminderTimingCommand alloc] init];
	instance.seconds = seconds;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_MUTE_REMINDER_TIMING;
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
    return [NSString stringWithFormat:@"<BRConfigureMuteReminderTimingCommand %p> seconds=0x%04X",
            self, self.seconds];
}

@end
