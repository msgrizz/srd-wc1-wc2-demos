//
//  BRServiceSubscriptionChangedEvent.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"
#import "BRSubscribeToServiceCommand.h"


@interface BRServiceSubscriptionChangedEvent : BREvent

@property(nonatomic,readonly)	BRServiceID					serviceID;
@property(nonatomic,readonly)	BRCharacteristicID			characteristicID;
@property(nonatomic,readonly)	BRServiceSubscriptionMode	mode;
@property(nonatomic,readonly)	uint16_t					period;

@end
