//
//  BRConversationDynamicsReportEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConversationDynamicsReportEvent.h"
#import "BRMessage_Private.h"




@interface BRConversationDynamicsReportEvent ()

@property(nonatomic,assign,readwrite) uint16_t timePeriod;
@property(nonatomic,assign,readwrite) uint16_t farEndDuration;
@property(nonatomic,assign,readwrite) uint16_t nearEndDuration;
@property(nonatomic,assign,readwrite) uint16_t crosstalkDuration;
@property(nonatomic,assign,readwrite) uint16_t noTalkDuration;


@end


@implementation BRConversationDynamicsReportEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONVERSATION_DYNAMICS_REPORT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"timePeriod", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"farEndDuration", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"nearEndDuration", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"crosstalkDuration", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"noTalkDuration", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConversationDynamicsReportEvent %p> timePeriod=0x%04X, farEndDuration=0x%04X, nearEndDuration=0x%04X, crosstalkDuration=0x%04X, noTalkDuration=0x%04X",
            self, self.timePeriod, self.farEndDuration, self.nearEndDuration, self.crosstalkDuration, self.noTalkDuration];
}

@end
