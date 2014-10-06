//
//  BRSetTimeweightedAveragePeriodCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetTimeweightedAveragePeriodCommand.h"
#import "BRMessage_Private.h"


const uint8_t SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod2hours = 1;
const uint8_t SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod4hours = 2;
const uint8_t SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod6hours = 3;
const uint8_t SetTimeweightedAveragePeriodCommand_Twa_TwaPeriod8hours = 4;


@implementation BRSetTimeweightedAveragePeriodCommand

#pragma mark - Public

+ (BRSetTimeweightedAveragePeriodCommand *)commandWithTwa:(uint8_t)twa
{
	BRSetTimeweightedAveragePeriodCommand *instance = [[BRSetTimeweightedAveragePeriodCommand alloc] init];
	instance.twa = twa;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_TIMEWEIGHTED_AVERAGE_PERIOD;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"twa", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetTimeweightedAveragePeriodCommand %p> twa=0x%02X",
            self, self.twa];
}

@end
