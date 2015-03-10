//
//  BRConfigureCallerAnnouncementCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRConfigureCallerAnnouncementCommand.h"
#import "BRMessage_Private.h"


@implementation BRConfigureCallerAnnouncementCommand

#pragma mark - Public

+ (BRConfigureCallerAnnouncementCommand *)commandWithValue:(uint8_t)value
{
	BRConfigureCallerAnnouncementCommand *instance = [[BRConfigureCallerAnnouncementCommand alloc] init];
	instance.value = value;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_CALLER_ANNOUNCEMENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"value", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureCallerAnnouncementCommand %p> value=0x%02X",
            self, self.value];
}

@end
