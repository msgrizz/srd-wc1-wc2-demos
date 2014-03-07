//
//  BRQueryWearingStateSettingResponse.h
//  PLTDevice
//
//  Created by Davis, Morgan on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"


@interface BRQueryWearingStateSettingResponse : BRSettingResponse

@property(nonatomic,readonly) BOOL isBeingWorn;

@end
