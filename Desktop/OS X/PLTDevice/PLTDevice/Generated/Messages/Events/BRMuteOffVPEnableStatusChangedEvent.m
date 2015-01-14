//
//  BRMuteOffVPEnableStatusChangedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMuteOffVPEnableStatusChangedEvent.h"
#import "BRMessage_Private.h"


@interface BRMuteOffVPEnableStatusChangedEvent ()

@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRMuteOffVPEnableStatusChangedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_MUTE_OFF_VP_ENABLE_STATUS_CHANGED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"enable", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRMuteOffVPEnableStatusChangedEvent %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
