//
//  BRQueryServicesDataSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRQueryServicesDataSettingRequest.h"
#import "BRMessage_Private.h"


const uint16_t QueryServicesDataSettingRequest_Characteristic_WearingDon = 0x00;
const uint16_t QueryServicesDataSettingRequest_Characteristic_WearingDoff = 0x01;
const uint16_t QueryServicesDataSettingRequest_Characteristic_TapXUp = 0x01;
const uint16_t QueryServicesDataSettingRequest_Characteristic_TapXDown = 0x02;
const uint16_t QueryServicesDataSettingRequest_Characteristic_TapYUp = 0x03;
const uint16_t QueryServicesDataSettingRequest_Characteristic_TapYDown = 0x04;
const uint16_t QueryServicesDataSettingRequest_Characteristic_TapZUp = 0x05;
const uint16_t QueryServicesDataSettingRequest_Characteristic_TapZDown = 0x06;
const uint16_t QueryServicesDataSettingRequest_Characteristic_CalibrateStatus_None = 0x00;
const uint16_t QueryServicesDataSettingRequest_Characteristic_CalibrateStatus_Step1 = 0x01;
const uint16_t QueryServicesDataSettingRequest_Characteristic_CalibrateStatus_Step2 = 0x02;
const uint16_t QueryServicesDataSettingRequest_Characteristic_CalibrateStatus_Calibrated = 0x03;
const uint16_t QueryServicesDataSettingRequest_Characteristic_Button_Up = 0x01;
const uint16_t QueryServicesDataSettingRequest_Characteristic_Button_Down = 0x00;


@implementation BRQueryServicesDataSettingRequest

#pragma BRSettingRequest

+ (BRQueryServicesDataSettingRequest *)requestWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic
{
	BRQueryServicesDataSettingRequest *instance = [[BRQueryServicesDataSettingRequest alloc] init];
	instance.serviceID = serviceID;
	instance.characteristic = characteristic;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_QUERY_SERVICES_DATA_SETTING_REQUEST;
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
    return [NSString stringWithFormat:@"<BRQueryServicesDataSettingRequest %p> serviceID=0x%04X, characteristic=0x%04X",
            self, self.serviceID, self.characteristic];
}

@end
