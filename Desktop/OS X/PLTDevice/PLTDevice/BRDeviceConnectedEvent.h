//
//  BRDeviceConnectedEvent.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


@interface BRDeviceConnectedEvent : BREvent

@property(nonatomic,readonly) uint8_t port;

@end
