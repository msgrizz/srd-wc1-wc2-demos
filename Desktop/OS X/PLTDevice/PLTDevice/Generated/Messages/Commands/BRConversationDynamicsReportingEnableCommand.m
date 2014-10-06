//
//  BRConversationDynamicsReportingEnableCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConversationDynamicsReportingEnableCommand.h"
#import "BRMessage_Private.h"




@implementation BRConversationDynamicsReportingEnableCommand

#pragma mark - Public

+ (BRConversationDynamicsReportingEnableCommand *)commandWithEnable:(BOOL)enable
{
	BRConversationDynamicsReportingEnableCommand *instance = [[BRConversationDynamicsReportingEnableCommand alloc] init];
	instance.enable = enable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONVERSATION_DYNAMICS_REPORTING_ENABLE;
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
    return [NSString stringWithFormat:@"<BRConversationDynamicsReportingEnableCommand %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
