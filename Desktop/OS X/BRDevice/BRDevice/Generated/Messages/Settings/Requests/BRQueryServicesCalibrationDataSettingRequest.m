//
//  BRQueryServicesCalibrationDataSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRQueryServicesCalibrationDataSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRQueryServicesCalibrationDataSettingRequest

#pragma BRSettingRequest

+ (BRQueryServicesCalibrationDataSettingRequest *)requestWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic
{
	BRQueryServicesCalibrationDataSettingRequest *instance = [[BRQueryServicesCalibrationDataSettingRequest alloc] init];
	instance.serviceID = serviceID;
	instance.characteristic = characteristic;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_QUERY_SERVICES_CALIBRATION_DATA_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serviceID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRQueryServicesCalibrationDataSettingRequest %p> serviceID=0x%04X, characteristic=0x%04X",
            self, self.serviceID, self.characteristic];
}

@end
