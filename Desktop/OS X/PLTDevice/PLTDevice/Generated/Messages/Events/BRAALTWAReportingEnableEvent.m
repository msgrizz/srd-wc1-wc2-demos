//
//  BRAALTWAReportingEnableEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAALTWAReportingEnableEvent.h"
#import "BRMessage_Private.h"




@interface BRAALTWAReportingEnableEvent ()

@property(nonatomic,assign,readwrite) BOOL enable;


@end


@implementation BRAALTWAReportingEnableEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_TWA_REPORTING_ENABLE_EVENT;
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
    return [NSString stringWithFormat:@"<BRAALTWAReportingEnableEvent %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
