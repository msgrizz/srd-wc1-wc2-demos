//
//  PLTOrientationTrackingInfo_Internal.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTOrientationTrackingInfo.h"


@interface PLTOrientationTrackingInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp
   rawQuaternion:(PLTQuaternion)rawQuaternion referenceQuaternion:(PLTQuaternion)referenceQuaternion;

@end
