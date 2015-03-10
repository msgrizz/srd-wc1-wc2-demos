//
//  BRHeadsetCallStatusSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_HEADSET_CALL_STATUS_SETTING_RESULT 0x0E22



@interface BRHeadsetCallStatusSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t numberOfDevices;
@property(nonatomic,readonly) uint8_t connectionId;
@property(nonatomic,readonly) uint8_t state;
@property(nonatomic,readonly) NSString * number;
@property(nonatomic,readonly) NSString * name;


@end
