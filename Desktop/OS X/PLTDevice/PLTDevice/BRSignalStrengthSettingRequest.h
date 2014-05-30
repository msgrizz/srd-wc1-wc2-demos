//
//  BRSignalStrengthSettingRequest.h
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


@interface BRSignalStrengthSettingRequest : BRSettingRequest

+ (BRSignalStrengthSettingRequest *)requestWithConnectionID:(int)conncetionID;

@property(nonatomic,readonly) int conncetionID;

@end
