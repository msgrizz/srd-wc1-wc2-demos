//
//  BRHardwareBatteryMeterSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRHardwareBatteryMeterSettingResult.h"
#import "BRMessage_Private.h"


@interface BRHardwareBatteryMeterSettingResult ()

@property(nonatomic,strong,readwrite) NSData * datapacket;


@end


@implementation BRHardwareBatteryMeterSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HARDWARE_BATTERY_METER_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"datapacket", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHardwareBatteryMeterSettingResult %p> datapacket=%@",
            self, self.datapacket];
}

@end
