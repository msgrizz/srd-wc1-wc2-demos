//
//  BROrientationTrackingEvent.h
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BREvent.h"
#import "PLTOrientationTrackingInfo.h" // this is not cool.


@interface BROrientationTrackingEvent : BREvent

@property(nonatomic,readonly) PLTEulerAngles    rawEulerAngles;
@property(nonatomic,readonly) PLTQuaternion     rawQuaternion;

@end
