//
//  BRLEDStatusGenericSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_LED_STATUS_GENERIC_SETTING_RESULT 0x0E07



@interface BRLEDStatusGenericSettingResult : BRSettingResult

@property(nonatomic,readonly) NSData * iD;
@property(nonatomic,readonly) NSData * color;
@property(nonatomic,readonly) NSData * state;


@end
