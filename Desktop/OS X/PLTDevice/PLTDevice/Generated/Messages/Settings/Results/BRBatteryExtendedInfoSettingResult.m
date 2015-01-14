//
//  BRBatteryExtendedInfoSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRBatteryExtendedInfoSettingResult.h"
#import "BRMessage_Private.h"


@interface BRBatteryExtendedInfoSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t voltage;
@property(nonatomic,assign,readwrite) uint16_t remainingcapacity;
@property(nonatomic,assign,readwrite) int16_t current;
@property(nonatomic,assign,readwrite) uint8_t stateofcharge;
@property(nonatomic,assign,readwrite) uint8_t temperature;
@property(nonatomic,assign,readwrite) uint16_t totalcapacity;
@property(nonatomic,assign,readwrite) uint16_t totaltalktime;
@property(nonatomic,assign,readwrite) uint16_t numchargecycles;
@property(nonatomic,assign,readwrite) uint16_t numfullcharges;


@end


@implementation BRBatteryExtendedInfoSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BATTERY_EXTENDED_INFO_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"voltage", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"remainingcapacity", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"current", @"type": @(BRPayloadItemTypeShort)},
			@{@"name": @"stateofcharge", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"temperature", @"type": @(BRPayloadItemTypeByte)},
			@{@"name": @"totalcapacity", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"totaltalktime", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"numchargecycles", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"numfullcharges", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBatteryExtendedInfoSettingResult %p> voltage=0x%04X, remainingcapacity=0x%04X, current=0x%04X, stateofcharge=0x%02X, temperature=0x%02X, totalcapacity=0x%04X, totaltalktime=0x%04X, numchargecycles=0x%04X, numfullcharges=0x%04X",
            self, self.voltage, self.remainingcapacity, self.current, self.stateofcharge, self.temperature, self.totalcapacity, self.totaltalktime, self.numchargecycles, self.numfullcharges];
}

@end
