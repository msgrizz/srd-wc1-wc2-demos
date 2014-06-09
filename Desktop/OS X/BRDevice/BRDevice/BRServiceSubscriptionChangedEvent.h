//
//  BRServiceSubscriptionChangedEvent.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


@interface BRServiceSubscriptionChangedEvent : BREvent

@property(nonatomic,readonly)	uint16_t	serviceID;
@property(nonatomic,readonly)	uint16_t	characteristicID;
@property(nonatomic,readonly)	uint16_t	mode;
@property(nonatomic,readonly)	uint16_t	period;

@end
