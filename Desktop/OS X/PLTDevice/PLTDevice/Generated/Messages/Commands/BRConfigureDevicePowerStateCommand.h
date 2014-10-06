//
//  BRConfigureDevicePowerStateCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_DEVICE_POWER_STATE 0x0814

extern const uint8_t ConfigureDevicePowerStateCommand_DeviceState_PowerOff;
extern const uint8_t ConfigureDevicePowerStateCommand_DeviceState_PowerOn;
extern const uint8_t ConfigureDevicePowerStateCommand_DeviceState_Restart;
extern const uint8_t ConfigureDevicePowerStateCommand_DeviceState_Hibernate;
extern const uint8_t ConfigureDevicePowerStateCommand_DeviceState_UpGrade;


@interface BRConfigureDevicePowerStateCommand : BRCommand

+ (BRConfigureDevicePowerStateCommand *)commandWithDeviceState:(uint8_t)deviceState;

@property(nonatomic,assign) uint8_t deviceState;


@end
