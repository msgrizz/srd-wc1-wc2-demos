//
//  BRUSBPIDSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_USB_PID_SETTING_RESULT 0x0A02



@interface BRUSBPIDSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t pid;


@end
