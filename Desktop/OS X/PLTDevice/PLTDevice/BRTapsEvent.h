//
//  BRTapsEvent.h
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"
#import "BRTapsSettingResponse.h"
#import "PLTTapsInfo.h" // this is not cool.


@interface BRTapsEvent : BREvent

@property(nonatomic,readonly) uint8_t           taps;
@property(nonatomic,readonly) PLTTapDirection   direction;

@end
