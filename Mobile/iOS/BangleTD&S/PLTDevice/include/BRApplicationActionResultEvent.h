//
//  BRApplicationActionResultEvent.h
//  PLTDevice
//
//  Created by Morgan Davis on 6/4/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


@interface BRApplicationActionResultEvent : BREvent

@property(nonatomic,readonly)	uint16_t	applicationID;
@property(nonatomic,readonly)	uint16_t	action;
@property(nonatomic,readonly)	NSData		*operatingData;
@property(nonatomic,readonly)	NSData		*resultData;

@end
