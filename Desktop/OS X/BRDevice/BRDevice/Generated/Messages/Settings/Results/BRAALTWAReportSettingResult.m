//
//  BRAALTWAReportSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAALTWAReportSettingResult.h"
#import "BRMessage_Private.h"


@interface BRAALTWAReportSettingResult ()



@end


@implementation BRAALTWAReportSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_TWA_REPORT_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRAALTWAReportSettingResult %p>",
            self];
}

@end
