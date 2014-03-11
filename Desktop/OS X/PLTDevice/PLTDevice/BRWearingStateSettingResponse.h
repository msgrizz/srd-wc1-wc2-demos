//
//  BRQueryWearingStateSettingResponse.h
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"


@interface BRWearingStateSettingResponse : BRSettingResponse

@property(nonatomic,readonly) BOOL isBeingWorn;

@end
