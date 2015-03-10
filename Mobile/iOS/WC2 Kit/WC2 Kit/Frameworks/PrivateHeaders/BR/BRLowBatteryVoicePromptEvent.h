//
//  BRLowBatteryVoicePromptEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_LOW_BATTERY_VOICE_PROMPT_EVENT 0x0A28



@interface BRLowBatteryVoicePromptEvent : BREvent

@property(nonatomic,readonly) uint8_t urgency;


@end
