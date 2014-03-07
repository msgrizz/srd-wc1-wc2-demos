//
//  BRQueryServiceDataSettingRequest.h
//  PLTDevice
//
//  Created by Davis, Morgan on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


@interface BRQueryServiceDataSettingRequest : BRSettingRequest

+ (BRQueryServiceDataSettingRequest *)requestWithServiceID:(uint16_t)serviceID;

@property(nonatomic,assign) uint16_t   serviceID;

@end
