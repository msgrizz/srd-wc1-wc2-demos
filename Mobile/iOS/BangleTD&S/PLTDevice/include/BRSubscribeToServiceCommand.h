//
//  BRSubscribeToServicesCommandRequest.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


typedef enum {
    BRServiceIDOrientationTracking =    0x0000,
    BRServiceIDPedometer =              0x0002,
    BRServiceIDFreeFall =               0x0003,
    BRServiceIDTaps =                   0x0004,
    BRServiceIDMagCal =                 0x0005,
    BRServiceIDGyroCal =                0x0006,
	
#warning BANGLE
	BRServiceIDAmbientHumidity =		0x0008,
	BRServiceIDAmbientLight =			0x0009,
	// optical proximity
	BRServiceIDAmbientTemperature =		0x000B,
	// ambient temp 2
	BRServiceIDSkinTemperature =		0x000D,
	BRServiceIDSkinConductivity =		0x000E,
	BRServiceIDAmbientPressure =		0x000F,
	BRServiceIDHeartRate =				0x0010
} BRServiceID;

typedef enum {
    BRCharacteristicIDBase =            0x0000
} BRCharacteristicID;

typedef enum {
    BRServiceSubscriptionModeOff =      0,
    BRServiceSubscriptionModeOnChange = 1,
    BRServiceSubscriptionModePeriodic = 2
} BRServiceSubscriptionMode;


@interface BRSubscribeToServiceCommand : BRCommand

+ (BRSubscribeToServiceCommand *)commandWithServiceID:(uint16_t)serviceID mode:(uint16_t)mode period:(uint16_t)period;

@property(nonatomic,assign) BRServiceID					serviceID;
@property(nonatomic,assign) BRServiceSubscriptionMode   mode;
@property(nonatomic,assign) uint16_t					period;

@end
