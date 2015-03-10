//
//  BRDeviceProtocolVersionMessage.h
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIncomingMessage.h"


@interface BRDeviceProtocolVersionMessage : BRIncomingMessage

@property(nonatomic,readonly) uint8_t	minimumVersion;
@property(nonatomic,readonly) uint8_t	maximumVersion;

@end
