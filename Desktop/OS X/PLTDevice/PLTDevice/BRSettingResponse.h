//
//  BRCommandResponse.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIncomingMessage.h"


typedef enum {
    BRSettingResponseIDWearingState =           0x0202,
    BRSettingResponseIDSignalStrength =         0x0800,
#ifdef OLD_SKEWL_IDS
    BRSettingResponseIDDeviceInfo =             0xFF18,
    BRSettingResponseIDSeaviceData =            0xFF13,
#else
	BRSettingResponseIDDeviceInfo =             0xFF20,
	BRSettingResponseIDSeaviceData =            0xFF0D,
#endif
	BRSettingResponseIDGenesGUID =				0x0A1E,
	BRSettingResponseIDProductName =			0x0A00,
	BRSettingResponseIDConnectionStatus =		0x0C00
} BRSettingResponseID;


@interface BRSettingResponse : BRIncomingMessage

+ (BRSettingResponse *)settingResponseWithData:(NSData *)data;

@end
