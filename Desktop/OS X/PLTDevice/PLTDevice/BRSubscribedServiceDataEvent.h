//
//  BRSubscribedServiceDataEvent.h
//  PLTDevice
//
//  Created by Morgan Davis on 6/20/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


@interface BRSubscribedServiceDataEvent : BREvent

@property(nonatomic,readonly)	uint16_t	serviceID;
@property(nonatomic,readonly)	uint16_t	characteristic;
@property(nonatomic,readonly)	NSData		*serviceData;

@end
