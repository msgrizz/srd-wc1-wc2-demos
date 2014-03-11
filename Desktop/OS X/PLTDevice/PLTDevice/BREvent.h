//
//  BREvent.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    BREventIDWearingStateChanged =              0x0200,
    BREventIDSignalStrength =                   0x0806,
    BREventIDServiceDataChanged =               0xFF1A,
    BREventIDServiceSubscriptionChanged =       0xFF0A,
    BREventIDDeviceConnected =                  0x0C00,
    BREventIDDeviceDisconnected =               0x0C02
} BREventID;


@interface BREvent : NSObject {
    
    NSData      *_data;
}

+ (BREvent *)eventWithData:(NSData *)data;
- (id)initWithData:(NSData *)data;
- (void)parseData;

@property(nonatomic,strong) NSData *data;

@end
