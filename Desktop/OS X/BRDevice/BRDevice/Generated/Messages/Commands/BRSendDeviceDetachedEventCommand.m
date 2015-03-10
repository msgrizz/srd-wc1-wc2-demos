//
//  BRSendDeviceDetachedEventCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSendDeviceDetachedEventCommand.h"
#import "BRMessage_Private.h"


@implementation BRSendDeviceDetachedEventCommand

#pragma mark - Public

+ (BRSendDeviceDetachedEventCommand *)commandWithMilliseconds:(int16_t)milliseconds
{
	BRSendDeviceDetachedEventCommand *instance = [[BRSendDeviceDetachedEventCommand alloc] init];
	instance.milliseconds = milliseconds;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SEND_DEVICE_DETACHED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"milliseconds", @"type": @(BRPayloadItemTypeShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSendDeviceDetachedEventCommand %p> milliseconds=0x%04X",
            self, self.milliseconds];
}

@end
