//
//  PLTProximityInfo_Internal.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTProximityInfo.h"


@interface PLTProximityInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp pcProximity:(PLTProximity)pcProximity mobileProximity:(PLTProximity)mobileProximity;

@end
