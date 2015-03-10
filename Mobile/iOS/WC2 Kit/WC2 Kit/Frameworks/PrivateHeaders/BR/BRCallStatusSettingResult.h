//
//  BRCallStatusSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_CALL_STATUS_SETTING_RESULT 0x0E02



@interface BRCallStatusSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t state;
@property(nonatomic,readonly) NSString * number;


@end
