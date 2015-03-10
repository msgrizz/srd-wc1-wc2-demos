//
//  BRMuteAlertSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_MUTE_ALERT_SETTING_RESULT 0x040A



@interface BRMuteAlertSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t mode;
@property(nonatomic,readonly) uint8_t parameter;


@end
