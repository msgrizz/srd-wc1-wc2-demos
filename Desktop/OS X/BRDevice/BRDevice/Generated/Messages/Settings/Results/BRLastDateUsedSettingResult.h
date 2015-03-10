//
//  BRLastDateUsedSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_LAST_DATE_USED_SETTING_RESULT 0x0A09



@interface BRLastDateUsedSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t month;
@property(nonatomic,readonly) uint16_t day;
@property(nonatomic,readonly) uint32_t year;


@end
