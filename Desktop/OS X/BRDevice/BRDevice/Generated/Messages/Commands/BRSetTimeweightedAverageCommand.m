//
//  BRSetTimeweightedAverageCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetTimeweightedAverageCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetTimeweightedAverageCommand

#pragma mark - Public

+ (BRSetTimeweightedAverageCommand *)commandWithTwa:(uint8_t)twa
{
	BRSetTimeweightedAverageCommand *instance = [[BRSetTimeweightedAverageCommand alloc] init];
	instance.twa = twa;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_TIMEWEIGHTED_AVERAGE;
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
    return [NSString stringWithFormat:@"<BRSetTimeweightedAverageCommand %p> twa=0x%02X",
            self, self.twa];
}

@end
