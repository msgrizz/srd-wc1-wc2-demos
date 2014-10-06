//
//  BRCalibrateServicesCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCalibrateServicesCommand.h"
#import "BRMessage_Private.h"


const uint16_t CalibrateServicesCommand_Characteristic_HeadOrientation_Cal = 0x0000;
const uint16_t CalibrateServicesCommand_Characteristic_Pedometer_Cal = 0x0000;
const uint16_t CalibrateServicesCommand_Characteristic_FreeFall_Cal = 0x0000;
const uint16_t CalibrateServicesCommand_Characteristic_Taps_Cal = 0x0000;
const uint16_t CalibrateServicesCommand_Characteristic_AmbientTemp1_Cal = 0x0000;
const uint16_t CalibrateServicesCommand_Characteristic_AmbientTemp2_Cal = 0x0000;
const uint16_t CalibrateServicesCommand_Characteristic_SkinTemp_Cal = 0x0000;
const uint16_t CalibrateServicesCommand_Characteristic_OpticalSensor_Cal = 0x0000;


@implementation BRCalibrateServicesCommand

#pragma mark - Public

+ (BRCalibrateServicesCommand *)commandWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic calibrationData:(NSData *)calibrationData
{
	BRCalibrateServicesCommand *instance = [[BRCalibrateServicesCommand alloc] init];
	instance.serviceID = serviceID;
	instance.characteristic = characteristic;
	instance.calibrationData = calibrationData;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CALIBRATE_SERVICES;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serviceID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"calibrationData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCalibrateServicesCommand %p> serviceID=0x%04X, characteristic=0x%04X, calibrationData=%@",
            self, self.serviceID, self.characteristic, self.calibrationData];
}

@end
