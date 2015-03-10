//
//  BRConversationDynamicsReportingTimePeriodCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRConversationDynamicsReportingTimePeriodCommand.h"
#import "BRMessage_Private.h"


@implementation BRConversationDynamicsReportingTimePeriodCommand

#pragma mark - Public

+ (BRConversationDynamicsReportingTimePeriodCommand *)commandWithTimePeriod:(uint32_t)timePeriod
{
	BRConversationDynamicsReportingTimePeriodCommand *instance = [[BRConversationDynamicsReportingTimePeriodCommand alloc] init];
	instance.timePeriod = timePeriod;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"timePeriod", @"type": @(BRPayloadItemTypeUnsignedInt)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConversationDynamicsReportingTimePeriodCommand %p> timePeriod=0x%08X",
            self, self.timePeriod];
}

@end
