//
//  BRVoiceSilentDetectedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_VOICE_SILENT_DETECTED_EVENT 0x0816



@interface BRVoiceSilentDetectedEvent : BREvent

@property(nonatomic,readonly) uint8_t mode;


@end
