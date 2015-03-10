//
//  BRFindHeadsetLEDAlertStatusChangedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_FIND_HEADSET_LED_ALERT_STATUS_CHANGED_EVENT 0x0808



@interface BRFindHeadsetLEDAlertStatusChangedEvent : BREvent

@property(nonatomic,readonly) BOOL enable;
@property(nonatomic,readonly) uint8_t timeout;


@end
