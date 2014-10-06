//
//  BRConversationDynamicsReportingEnableEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConversationDynamicsReportingEnableEvent.h"
#import "BRMessage_Private.h"




@interface BRConversationDynamicsReportingEnableEvent ()

@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRConversationDynamicsReportingEnableEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONVERSATION_DYNAMICS_REPORTING_ENABLE_EVENT;
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
    return [NSString stringWithFormat:@"<BRConversationDynamicsReportingEnableEvent %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
