//
//  BRConfigureCallerAnnouncementEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureCallerAnnouncementEvent.h"
#import "BRMessage_Private.h"




@interface BRConfigureCallerAnnouncementEvent ()

@property(nonatomic,assign,readwrite) uint8_t value;


@end


@implementation BRConfigureCallerAnnouncementEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_CALLER_ANNOUNCEMENT_EVENT;
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
    return [NSString stringWithFormat:@"<BRConfigureCallerAnnouncementEvent %p> value=0x%02X",
            self, self.value];
}

@end
