//
//  BRServiceDataSettingRequest.h
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


@interface BRServiceDataSettingRequest : BRSettingRequest

+ (BRServiceDataSettingRequest *)requestWithServiceID:(uint16_t)serviceID;

@property(nonatomic,assign) uint16_t   serviceID;

@end
