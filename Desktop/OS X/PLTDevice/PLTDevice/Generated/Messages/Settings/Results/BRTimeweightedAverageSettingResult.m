//
//  BRTimeweightedAverageSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTimeweightedAverageSettingResult.h"
#import "BRMessage_Private.h"


@interface BRTimeweightedAverageSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t twa;


@end


@implementation BRTimeweightedAverageSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TIMEWEIGHTED_AVERAGE_SETTING_RESULT;
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
    return [NSString stringWithFormat:@"<BRTimeweightedAverageSettingResult %p> twa=0x%02X",
            self, self.twa];
}

@end
