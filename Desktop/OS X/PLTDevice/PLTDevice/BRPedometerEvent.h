//
//  BRPedometerEvent.h
//  BTSniffer
//
//  Created by Davis, Morgan on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


@interface BRPedometerEvent : BREvent

@property(nonatomic,readonly) NSUInteger steps;

@end
