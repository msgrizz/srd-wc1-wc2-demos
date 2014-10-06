//
//  BRHalCurrentVolumeSettingRequest.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


#define BR_HAL_CURRENT_VOLUME_SETTING_REQUEST 0x1102



@interface BRHalCurrentVolumeSettingRequest : BRSettingRequest

+ (BRHalCurrentVolumeSettingRequest *)requestWithScenario:(uint16_t)scenario volumes:(NSData *)volumes;

@property(nonatomic,assign) uint16_t scenario;
@property(nonatomic,strong) NSData * volumes;


@end
