//
//  BRFirmwareVersionSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_FIRMWARE_VERSION_SETTING_RESULT 0x0A04



@interface BRFirmwareVersionSettingResult : BRSettingResult

@property(nonatomic,readonly) uint16_t buildTarget;
@property(nonatomic,readonly) uint16_t _release;


@end
