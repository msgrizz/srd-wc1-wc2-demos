//
//  BRGetSecondInboundCallRingTypeSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING_RESULT 0x0406



@interface BRGetSecondInboundCallRingTypeSettingResult : BRSettingResult

@property(nonatomic,readonly) uint8_t ringType;


@end
