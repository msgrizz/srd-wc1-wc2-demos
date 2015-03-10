//
//  BRSetTimeweightedAverageEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetTimeweightedAverageEvent.h"
#import "BRMessage_Private.h"


@interface BRSetTimeweightedAverageEvent ()

@property(nonatomic,assign,readwrite) uint8_t twa;


@end


@implementation BRSetTimeweightedAverageEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_TIMEWEIGHTED_AVERAGE_EVENT;
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
    return [NSString stringWithFormat:@"<BRSetTimeweightedAverageEvent %p> twa=0x%02X",
            self, self.twa];
}

@end
