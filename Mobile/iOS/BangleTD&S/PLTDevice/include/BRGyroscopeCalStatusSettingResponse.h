//
//  BRGyroscopeCalStatusSettingResponse.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"


@interface BRGyroscopeCalStatusSettingResponse : BRSettingResponse

@property(nonatomic,readonly) BOOL isCalibrated;

@end
