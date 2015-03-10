//
//  BRSettingResult.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIncomingMessage.h"


//typedef enum {
//    BRSettingResultIDWearingState =           0x0202,
//    BRSettingResultIDSignalStrength =         0x0800,
//#ifdef OLD_SKEWL_IDS
//    BRSettingResultIDDeviceInfo =             0xFF18,
//    BRSettingResultIDSeaviceData =            0xFF13,
//#else
//	BRSettingResultIDDeviceInfo =             0xFF20,
//	BRSettingResultIDSeaviceData =            0xFF0D,
//#endif@interface BRSettingResult : BRIncomingMessage

//	BRSettingResultIDGenesGUID =				0x0A1E,
//	BRSettingResultIDProductName =			0x0A00,
//	BRSettingResultIDConnectionStatus =		0x0C00,
//	BRSettingResultIDHeadsetCallStatus =		0x0E22
//} BRSettingResultID;


@interface BRSettingResult : BRIncomingMessage

@end
