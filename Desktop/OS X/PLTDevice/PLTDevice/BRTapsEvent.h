//
//  BRTapsEvent.h
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


@interface BRTapsEvent : BREvent

@property(nonatomic,readonly) uint8_t       count;
@property(nonatomic,readonly) uint8_t		direction;

@end
