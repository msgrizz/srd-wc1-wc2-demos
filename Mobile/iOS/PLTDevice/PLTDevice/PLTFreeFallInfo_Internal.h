//
//  PLTFreeFallInfo_Internal.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTFreeFallInfo.h"


@interface PLTFreeFallInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp freeFall:(BOOL)isInFreeFall;

@end
