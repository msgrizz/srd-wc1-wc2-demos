//
//  BRGyroscopeCalStatus.h
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"
#import "PLTGyroscopeCalibrationInfo.h" // this is not cool.


@interface BRGyroscopeCalStatusEvent : BREvent

@property(nonatomic,readonly) BOOL isCalibrated;

@end
