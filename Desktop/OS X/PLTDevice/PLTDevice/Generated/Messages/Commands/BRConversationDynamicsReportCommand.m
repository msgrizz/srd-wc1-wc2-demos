//
//  BRConversationDynamicsReportCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConversationDynamicsReportCommand.h"
#import "BRMessage_Private.h"


@implementation BRConversationDynamicsReportCommand

#pragma mark - Public

+ (BRConversationDynamicsReportCommand *)command
{
	BRConversationDynamicsReportCommand *instance = [[BRConversationDynamicsReportCommand alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONVERSATION_DYNAMICS_REPORT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[

			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConversationDynamicsReportCommand %p>",
            self];
}

@end
