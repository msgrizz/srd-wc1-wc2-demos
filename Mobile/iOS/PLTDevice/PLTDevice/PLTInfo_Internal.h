//
//  PLTInfo_Internal.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTInfo.h"


@interface PLTInfo()

- (id)initWithRequestType:(PLTInfoRequestType)requestType timestamp:(NSDate *)timestamp;

@property(nonatomic, readwrite)	PLTInfoRequestType	requestType;

@end
