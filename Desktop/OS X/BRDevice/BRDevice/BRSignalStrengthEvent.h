//
//  BRSignalStrengthEvent.h
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


@interface BRSignalStrengthEvent : BREvent

@property(nonatomic,readonly) uint8_t	connectionID;
@property(nonatomic,readonly) uint8_t	strength;
@property(nonatomic,readonly) uint8_t	distance;

@end
