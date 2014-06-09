//
//  BRRemoteDevice.h
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDevice.h"


@interface BRRemoteDevice : BRDevice

@property(nonatomic,readonly)	BRDevice		*parent;
@property(nonatomic,readonly)	uint8_t			port;

@end
