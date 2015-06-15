//
//  BRAALTWAReportingEnableCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAALTWAReportingEnableCommand.h"
#import "BRMessage_Private.h"


@implementation BRAALTWAReportingEnableCommand

#pragma mark - Public

+ (BRAALTWAReportingEnableCommand *)commandWithEnable:(BOOL)enable
{
	BRAALTWAReportingEnableCommand *instance = [[BRAALTWAReportingEnableCommand alloc] init];
	instance.enable = enable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_TWA_REPORTING_ENABLE;
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
    return [NSString stringWithFormat:@"<BRAALTWAReportingEnableCommand %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end