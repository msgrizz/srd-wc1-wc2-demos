//
//  BRAALAcousticIncidentReportingEnableCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRAALAcousticIncidentReportingEnableCommand.h"
#import "BRMessage_Private.h"


@implementation BRAALAcousticIncidentReportingEnableCommand

#pragma mark - Public

+ (BRAALAcousticIncidentReportingEnableCommand *)commandWithEnable:(BOOL)enable
{
	BRAALAcousticIncidentReportingEnableCommand *instance = [[BRAALAcousticIncidentReportingEnableCommand alloc] init];
	instance.enable = enable;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_AAL_ACOUSTIC_INCIDENT_REPORTING_ENABLE;
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
    return [NSString stringWithFormat:@"<BRAALAcousticIncidentReportingEnableCommand %p> enable=%@",
            self, (self.enable ? @"YES" : @"NO")];
}

@end
