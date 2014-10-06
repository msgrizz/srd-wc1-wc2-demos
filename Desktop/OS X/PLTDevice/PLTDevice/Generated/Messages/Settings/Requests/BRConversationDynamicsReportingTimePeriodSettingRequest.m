//
//  BRConversationDynamicsReportingTimePeriodSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConversationDynamicsReportingTimePeriodSettingRequest.h"
#import "BRMessage_Private.h"




@implementation BRConversationDynamicsReportingTimePeriodSettingRequest

#pragma BRSettingRequest

+ (BRConversationDynamicsReportingTimePeriodSettingRequest *)request
{
	BRConversationDynamicsReportingTimePeriodSettingRequest *instance = [[BRConversationDynamicsReportingTimePeriodSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRConversationDynamicsReportingTimePeriodSettingRequest %p>",
            self];
}

@end
