//
//  BROrientationTrackingEvent.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


typedef struct {
	double w;
	double x;
	double y;
	double z;
} BRQuaternion;


@interface BROrientationTrackingEvent : BREvent

@property(nonatomic,readonly) BRQuaternion		quaternion;

@end
