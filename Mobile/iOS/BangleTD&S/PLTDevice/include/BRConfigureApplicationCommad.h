//
//  BRConfigureApplicationCommad.h
//  PLTDevice
//
//  Created by Morgan Davis on 6/16/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


typedef enum {
	BRFeatureIDDisplayReadout =			0x0000,
	BRFeatureIDUnits =					0x0001,
	BRFeatureIDLockOnPowerup =			0x0002,
	BRFeatureIDLockOnDoff =				0x0003,
	BRFeatureIDEnableButtonLock =		0x0004,
	BRFeatureIDEnablePanicSequence =	0x0005,
	BRFeatureIDDateAndTime =			0x0006
} BRFeatureID;

typedef enum {
	BRDisplayReadoutCharacteristicHeartrate =		0x0000,
	BRDisplayReadoutCharacteristicPedometer =		0x0001,
	BRDisplayReadoutCharacteristicCompass =			0x0002,
	BRDisplayReadoutCharacteristicAltitude =		0x0003,
	BRDisplayReadoutCharacteristicAmbientTemp =		0x0004,
	BRDisplayReadoutCharacteristicAmbientHumidity =	0x0005,
	BRDisplayReadoutCharacteristicSkinTemp =		0x0006,
	BRDisplayReadoutCharacteristicSkinHumidity =	0x0007,
	BRDisplayReadoutCharacteristicLight =			0x0008
} BRDisplayReadoutCharacteristic;

typedef enum {
	BRUnitsCharacteristicConfiguration =				0x0000
} BRUnitsCharacteristic;

typedef enum {
	BRLockOnPowerupCharacteristicConfiguration =		0x0000
} BRLockOnPowerupCharacteristic;

typedef enum {
	BRLockOnDoffCharacteristicConfiguration =			0x0000
} BRLockOnDoffCharacteristic;

typedef enum {
	BREnableButtonLockCharacteristicConfiguration =		0x0000
} BREnableButtonLockCharacteristic;

typedef enum {
	BREnablePanicSequenceCharacteristicConfiguration =	0x0000
} BREnablePanicSequenceCharacteristic;

typedef enum {
	BRDateAndTimeCharacteristicConfiguration =			0x0000
} BRDateAndTimeCharacteristic;


@interface BRConfigureApplicationCommad : BRCommand

+ (BRConfigureApplicationCommad *)commandWithFeatureID:(uint16_t)featureID characteristic:(uint16_t)characteristic configurationData:(NSData *)configurationData;

@property(nonatomic,assign)		uint16_t	featureID;
@property(nonatomic,assign)		uint16_t	characteristic;
@property(nonatomic,strong)		NSData		*configurationData;

@end
