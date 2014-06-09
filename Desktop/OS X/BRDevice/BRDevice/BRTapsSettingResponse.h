//
//  BRTapsSettingResponse.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"


@interface BRTapsSettingResponse : BRSettingResponse

@property(nonatomic,readonly) uint8_t		count;
@property(nonatomic,readonly) uint8_t		direction;

@end
