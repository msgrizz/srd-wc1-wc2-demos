//
//  PLTPedometerInfo_Internal.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTPedometerInfo.h"


@interface PLTPedometerInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp steps:(NSUInteger)steps;

@end
