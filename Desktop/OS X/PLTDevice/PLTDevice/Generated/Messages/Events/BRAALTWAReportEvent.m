//
//  BRAALTWAReportEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAALTWAReportEvent.h"
#import "BRMessage_Private.h"




@interface BRAALTWAReportEvent ()

@property(nonatomic,assign,readwrite) uint8_t preLimiterLongTermSplEstimate;
@property(nonatomic,assign,readwrite) uint8_t postLimiterLongTermSplEstimate;


@end


@implementation BRAALTWAReportEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_TWA_REPORT_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"preLimiterLongTermSplEstimate", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"postLimiterLongTermSplEstimate", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRAALTWAReportEvent %p> preLimiterLongTermSplEstimate=0x%02X, postLimiterLongTermSplEstimate=0x%02X",
            self, self.preLimiterLongTermSplEstimate, self.postLimiterLongTermSplEstimate];
}

@end
