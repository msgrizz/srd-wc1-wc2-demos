//
//  BRMuteAlertSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_MUTE_ALERT_SETTING_RESULT 0x040A



@interface BRMuteAlertSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t mode;
@property(nonatomic,readonly) uint8_t parameter;


@end
