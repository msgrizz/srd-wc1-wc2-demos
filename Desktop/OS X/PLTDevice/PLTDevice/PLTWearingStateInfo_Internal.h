//
//  PLTWearingStateInfo_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTWearingStateInfo.h"


@interface PLTWearingStateInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp wearingState:(BOOL)isBeingWorn;

@end
