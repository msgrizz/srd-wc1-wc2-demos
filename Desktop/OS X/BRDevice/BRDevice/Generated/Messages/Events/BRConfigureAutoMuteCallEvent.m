//
//  BRConfigureAutoMuteCallEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRConfigureAutoMuteCallEvent.h"
#import "BRMessage_Private.h"


@interface BRConfigureAutoMuteCallEvent ()

@property(nonatomic,assign,readwrite) BOOL autoMuteCall;


@end


@implementation BRConfigureAutoMuteCallEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_AUTOMUTE_CALL_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"autoMuteCall", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureAutoMuteCallEvent %p> autoMuteCall=%@",
            self, (self.autoMuteCall ? @"YES" : @"NO")];
}

@end
