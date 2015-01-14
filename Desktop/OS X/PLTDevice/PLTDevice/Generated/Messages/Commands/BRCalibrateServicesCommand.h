//
//  BRCalibrateServicesCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CALIBRATE_SERVICES 0xFF01

#define BRDefinedValue_CalibrateServicesCommand_Characteristic_HeadOrientation_Cal 0x0000
#define BRDefinedValue_CalibrateServicesCommand_Characteristic_Pedometer_Cal 0x0000
#define BRDefinedValue_CalibrateServicesCommand_Characteristic_FreeFall_Cal 0x0000
#define BRDefinedValue_CalibrateServicesCommand_Characteristic_Taps_Cal 0x0000
#define BRDefinedValue_CalibrateServicesCommand_Characteristic_AmbientTemp1_Cal 0x0000
#define BRDefinedValue_CalibrateServicesCommand_Characteristic_AmbientTemp2_Cal 0x0000
#define BRDefinedValue_CalibrateServicesCommand_Characteristic_SkinTemp_Cal 0x0000
#define BRDefinedValue_CalibrateServicesCommand_Characteristic_OpticalSensor_Cal 0x0000


@interface BRCalibrateServicesCommand : BRCommand

+ (BRCalibrateServicesCommand *)commandWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic calibrationData:(NSData *)calibrationData;

@property(nonatomic,assign) uint16_t serviceID;
@property(nonatomic,assign) uint16_t characteristic;
@property(nonatomic,strong) NSData * calibrationData;


@end
