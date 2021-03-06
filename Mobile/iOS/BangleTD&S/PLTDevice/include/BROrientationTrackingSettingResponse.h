//
//  BROrientationTrackingSettingResponse.h
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"
#import "BROrientationTrackingEvent.h"


@interface BROrientationTrackingSettingResponse : BRSettingResponse

@property(nonatomic,readonly) BRQuaternion     quaternion;

@end
