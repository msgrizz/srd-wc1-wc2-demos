//
//  BRHostVersionNegotiateMessage.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/10/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROutgoingMessage.h"


@interface BRHostVersionNegotiateMessage : BROutgoingMessage

+ (BRHostVersionNegotiateMessage *)messageWithMinimumVersion:(uint8_t)minimumVersion maximumVersion:(uint8_t)maximumVersion;

@property(nonatomic,readonly) uint8_t	minimumVersion;
@property(nonatomic,readonly) uint8_t	maximumVersion;


@end
