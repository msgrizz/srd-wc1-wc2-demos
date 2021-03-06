//
//  BRBatteryInfoSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRBatteryInfoSettingResult.h"
#import "BRMessage_Private.h"


@interface BRBatteryInfoSettingResult ()

@property(nonatomic,assign,readwrite) uint8_t level;
@property(nonatomic,assign,readwrite) uint8_t numLevels;
@property(nonatomic,assign,readwrite) BOOL charging;
@property(nonatomic,assign,readwrite) uint16_t minutesOfTalkTime;
@property(nonatomic,assign,readwrite) BOOL talkTimeIsHighEstimate;


@end


@implementation BRBatteryInfoSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BATTERY_INFO_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"level", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"numLevels", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"charging", @"type": @(BRPayloadItemTypeBoolean)},
			@{@"name": @"minutesOfTalkTime", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"talkTimeIsHighEstimate", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBatteryInfoSettingResult %p> level=0x%02X, numLevels=0x%02X, charging=%@, minutesOfTalkTime=0x%04X, talkTimeIsHighEstimate=%@",
            self, self.level, self.numLevels, (self.charging ? @"YES" : @"NO"), self.minutesOfTalkTime, (self.talkTimeIsHighEstimate ? @"YES" : @"NO")];
}

@end
