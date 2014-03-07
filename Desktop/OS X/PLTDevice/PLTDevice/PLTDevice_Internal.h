//
//  PLTDevice_Internal.h
//  PLTDevice
//
//  Created by Davis, Morgan on 9/24/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//


@class PLTDevice;
@class EAAccessory;


@interface PLTDevice()

- (PLTDevice *)initWithAccessory:(EAAccessory *)anAccessory;

@property(nonatomic, retain)	EAAccessory		*accessory;

@end
