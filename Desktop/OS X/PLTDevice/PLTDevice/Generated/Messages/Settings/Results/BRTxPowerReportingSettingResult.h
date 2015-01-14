//
//  BRTxPowerReportingSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_TXPOWER_REPORTING_SETTING_RESULT 0x0810



@interface BRTxPowerReportingSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t connectionId;
@property(nonatomic,readonly) BOOL enable;


@end
