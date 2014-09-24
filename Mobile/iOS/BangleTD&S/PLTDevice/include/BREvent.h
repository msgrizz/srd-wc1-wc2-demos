//
//  BREvent.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIncomingMessage.h"


typedef enum {
    BREventIDWearingStateChanged =              0x0200,
    BREventIDSignalStrength =                   0x0806,
    BREventIDServiceDataChanged =               0xFF1A,
    BREventIDServiceSubscriptionChanged =       0xFF0A,
    BREventIDDeviceConnected =                  0x0C00,
    BREventIDDeviceDisconnected =               0x0C02,
	BREventIDApplicationActionResult =			0xFF1E
} BREventID;


@interface BREvent : BRIncomingMessage

+ (BREvent *)eventWithData:(NSData *)data;

@end
