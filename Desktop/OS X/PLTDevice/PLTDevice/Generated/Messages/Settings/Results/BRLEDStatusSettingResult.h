//
//  BRLEDStatusSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_LED_STATUS_SETTING_RESULT 0x0E20



@interface BRLEDStatusSettingResult : BRSettingResult

@property(nonatomic,readonly) NSData * lEDIndication;


@end
