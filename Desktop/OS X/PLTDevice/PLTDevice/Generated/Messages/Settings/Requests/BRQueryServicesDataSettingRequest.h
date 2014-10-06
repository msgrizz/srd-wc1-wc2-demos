//
//  BRQueryServicesDataSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_QUERY_SERVICES_DATA_SETTING_REQUEST 0xFF0D

extern const uint16_t QueryServicesDataSettingRequest_Characteristic_WearingDon;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_WearingDoff;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_TapXUp;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_TapXDown;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_TapYUp;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_TapYDown;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_TapZUp;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_TapZDown;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_CalibrateStatus_None;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_CalibrateStatus_Step1;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_CalibrateStatus_Step2;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_CalibrateStatus_Calibrated;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_Button_Up;
extern const uint16_t QueryServicesDataSettingRequest_Characteristic_Button_Down;


@interface BRQueryServicesDataSettingRequest : BRSettingRequest

+ (BRQueryServicesDataSettingRequest *)requestWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic;

@property(nonatomic,assign) uint16_t serviceID;
@property(nonatomic,assign) uint16_t characteristic;


@end
