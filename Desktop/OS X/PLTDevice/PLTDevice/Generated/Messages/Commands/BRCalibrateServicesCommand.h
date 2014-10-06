//
//  BRCalibrateServicesCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CALIBRATE_SERVICES 0xFF01

extern const uint16_t CalibrateServicesCommand_Characteristic_HeadOrientation_Cal;
extern const uint16_t CalibrateServicesCommand_Characteristic_Pedometer_Cal;
extern const uint16_t CalibrateServicesCommand_Characteristic_FreeFall_Cal;
extern const uint16_t CalibrateServicesCommand_Characteristic_Taps_Cal;
extern const uint16_t CalibrateServicesCommand_Characteristic_AmbientTemp1_Cal;
extern const uint16_t CalibrateServicesCommand_Characteristic_AmbientTemp2_Cal;
extern const uint16_t CalibrateServicesCommand_Characteristic_SkinTemp_Cal;
extern const uint16_t CalibrateServicesCommand_Characteristic_OpticalSensor_Cal;


@interface BRCalibrateServicesCommand : BRCommand

+ (BRCalibrateServicesCommand *)commandWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic calibrationData:(NSData *)calibrationData;

@property(nonatomic,assign) uint16_t serviceID;
@property(nonatomic,assign) uint16_t characteristic;
@property(nonatomic,strong) NSData * calibrationData;


@end
