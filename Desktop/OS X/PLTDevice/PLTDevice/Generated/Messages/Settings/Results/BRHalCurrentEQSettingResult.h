//
//  BRHalCurrentEQSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_HAL_CURRENT_EQ_SETTING_RESULT 0x1104



@interface BRHalCurrentEQSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t scenario;
@property(nonatomic,readonly) uint16_t numberOfEQs;
@property(nonatomic,readonly) uint8_t eQId;
@property(nonatomic,readonly) NSData * eQSettings;


@end
