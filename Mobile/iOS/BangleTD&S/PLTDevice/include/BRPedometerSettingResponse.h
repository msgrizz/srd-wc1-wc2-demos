//
//  BRPedometerSettingResponse.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"


@interface BRPedometerSettingResponse : BRSettingResponse

@property(nonatomic,readonly) uint32_t steps;

@end
