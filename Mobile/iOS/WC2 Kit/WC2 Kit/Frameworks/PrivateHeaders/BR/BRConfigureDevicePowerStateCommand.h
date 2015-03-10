//
//  BRConfigureDevicePowerStateCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_DEVICE_POWER_STATE 0x0814

#define BRDefinedValue_ConfigureDevicePowerStateCommand_DeviceState_PowerOff 0x00
#define BRDefinedValue_ConfigureDevicePowerStateCommand_DeviceState_PowerOn 0x01
#define BRDefinedValue_ConfigureDevicePowerStateCommand_DeviceState_Restart 0x02
#define BRDefinedValue_ConfigureDevicePowerStateCommand_DeviceState_Hibernate 0x03
#define BRDefinedValue_ConfigureDevicePowerStateCommand_DeviceState_UpGrade 0x04


@interface BRConfigureDevicePowerStateCommand : BRCommand

+ (BRConfigureDevicePowerStateCommand *)commandWithDeviceState:(uint8_t)deviceState;

@property(nonatomic,assign) uint8_t deviceState;


@end
