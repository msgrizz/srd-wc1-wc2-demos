//
//  BRSubscribeToServicesCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSubscribeToServicesCommand.h"
#import "BRMessage_Private.h"


const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_HeadOrientation = 0x0000;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_Heading = 0x0001;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_Pedometer = 0x0002;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_FreeFall = 0x0003;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_Taps = 0x0004;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_MagnetometerCalibrationStatus = 0x0005;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_GyroscopeCalibrationStatus = 0x0006;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_Versions = 0x0007;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_Humidity = 0x0008;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_Light = 0x0009;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_OpticalProximity = 0x000a;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_AmbientTemp1 = 0x000b;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_AmbientTemp2 = 0x000c;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_SkinTemp = 0x000d;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_SkinConductivity = 0x000e;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_AmbientPressure = 0x000f;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_HeartRate = 0x0010;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_UI = 0x0011;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_RTC = 0x0012;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_Acceleration = 0x0013;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_AngularVelocity = 0x0014;
const uint16_t SubscribeToServicesCommand_ServiceID_ServiceID_MagneticField = 0x0015;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_HeadOrientation_QuaternionData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_HeadOrientation_EulerAnglesData = 0x0001;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_Pedometer_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_FreeFall_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_Taps_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_MagnetometerCalibrationStatus_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_GyroscopeCalibrationStatus_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_Versions_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_Humidity_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_Light_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_OpticalProximity_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_AmbientTemp1_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_AmbientTemp2_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_SkinTemp_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_SkinConductivity_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_AmbientPressure_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_HeartRate_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UIButton_Press = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_DisplayReadoutDisplay_HeartRate = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_DisplayReadoutDisplay_Pedometer = 0x0001;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_DisplayReadoutDisplay_Compass = 0x0002;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_DisplayReadoutDisplay_Altitude = 0x0003;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_DisplayReadoutDisplay_AmbientTemp = 0x0004;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_DisplayReadoutDisplay_AmbientHumidity = 0x0005;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_DisplayReadoutDisplay_SkinTemp = 0x0006;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_DisplayReadoutDisplay_SkinHumidity = 0x0007;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_DisplayReadoutDisplay_Light = 0x0008;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_Units_Configuration = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_LockOnPowerUp_Configuration = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_LockOnDoff_Configuration = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_EnableButtonLock_Configuration = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_EnablePanicSequence_Configuration = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_DateAndTime_Format = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UIScroll_DisplayMessage = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UIMarquee_DisplayMessage = 0x0001;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UI_FlipDisplay = 0x0002;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UI_RotateDisplay = 0x0003;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UI_DisplayMessage = 0x0004;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UI_ToggleDisplay = 0x0005;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UI_InvertDisplay = 0x0006;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UI_ClearDisplay = 0x0007;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UI_DisplayPunctuationState = 0x0008;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_UI_DisplayIconState = 0x0009;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_RTC_Configure = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_NFC_WriteData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_Acceleration_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_AngularVelocity_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Characteristic_Characteristic_MagneticField_ServiceData = 0x0000;
const uint16_t SubscribeToServicesCommand_Mode_ModeOff = 0;
const uint16_t SubscribeToServicesCommand_Mode_ModeOnCchange = 1;
const uint16_t SubscribeToServicesCommand_Mode_ModePeriodic = 2;


@implementation BRSubscribeToServicesCommand

#pragma mark - Public

+ (BRSubscribeToServicesCommand *)commandWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic mode:(uint16_t)mode period:(uint16_t)period
{
	BRSubscribeToServicesCommand *instance = [[BRSubscribeToServicesCommand alloc] init];
	instance.serviceID = serviceID;
	instance.characteristic = characteristic;
	instance.mode = mode;
	instance.period = period;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SUBSCRIBE_TO_SERVICES;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serviceID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"mode", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"period", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSubscribeToServicesCommand %p> serviceID=0x%04X, characteristic=0x%04X, mode=0x%04X, period=0x%04X",
            self, self.serviceID, self.characteristic, self.mode, self.period];
}

@end
