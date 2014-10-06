//
//  BREvent.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIncomingMessage.h"


//typedef enum {
//    BREventIDWearingStateChanged =              0x0200,
//    BREventIDSignalStrength =                   0x0806,
//    BREventIDDeviceConnected =                  0x0C00,
//    BREventIDDeviceDisconnected =               0x0C02,
//#ifdef OLD_SKEWL_IDS
//	BREventIDServiceDataChanged =               0xFF1A,
//	BREventIDServiceSubscriptionChanged =       0xFF0A,
//	BREventIDApplicationActionResult =			0xFF1E
//#else
//	BREventIDServiceDataChanged =               0xFF0D,
//	BREventIDServiceSubscriptionChanged =       0xFF0A,
//	BREventIDApplicationActionResult =			0xFF03,
//#endif
//	BREventIDCustomButton =						0x0802,
//	BREventIDHeadsetCallStatus =				0x0E22
//} BREventID;


@interface BREvent : BRIncomingMessage

@end
