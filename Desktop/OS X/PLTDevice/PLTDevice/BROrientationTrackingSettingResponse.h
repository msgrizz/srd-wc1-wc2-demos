//
//  BROrientationTrackingSettingResponse.h
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"
#import "PLTOrientationTrackingInfo.h" // this is not cool.


@interface BROrientationTrackingSettingResponse : BRSettingResponse

@property(nonatomic,readonly) PLTEulerAngles    rawEulerAngles;
@property(nonatomic,readonly) PLTQuaternion     rawQuaternion;

@end
