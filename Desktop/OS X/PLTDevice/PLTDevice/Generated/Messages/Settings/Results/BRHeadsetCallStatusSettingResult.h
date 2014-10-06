//
//  BRHeadsetCallStatusSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_HEADSET_CALL_STATUS_SETTING_RESULT 0x0E22



@interface BRHeadsetCallStatusSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t numberOfDevices;
@property(nonatomic,readonly) uint8_t connectionId;
@property(nonatomic,readonly) uint8_t state;
@property(nonatomic,readonly) NSString * number;


@end
