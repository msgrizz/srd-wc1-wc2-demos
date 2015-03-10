//
//  BRAALTWAReportCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRAALTWAReportCommand.h"
#import "BRMessage_Private.h"


@implementation BRAALTWAReportCommand

#pragma mark - Public

+ (BRAALTWAReportCommand *)command
{
	BRAALTWAReportCommand *instance = [[BRAALTWAReportCommand alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_TWA_REPORT;
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
    return [NSString stringWithFormat:@"<BRAALTWAReportCommand %p>",
            self];
}

@end
