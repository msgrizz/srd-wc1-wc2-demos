//
//  BRConversationDynamicsReportingTimePeriodSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConversationDynamicsReportingTimePeriodSettingResult.h"
#import "BRMessage_Private.h"




@interface BRConversationDynamicsReportingTimePeriodSettingResult ()

@property(nonatomic,assign,readwrite) uint32_t timePeriod;


@end


@implementation BRConversationDynamicsReportingTimePeriodSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRConversationDynamicsReportingTimePeriodSettingResult %p> timePeriod=0x%08X",
            self, self.timePeriod];
}

@end
