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

@property(nonatomic,assign) BRServiceID					serviceID;
@property(nonatomic,assign) BRCharacteristicID			characteristicID;
@property(nonatomic,assign) BRServiceSubscriptionMode	mode;
@property(nonatomic,assign) uint16_t					period;

@end
