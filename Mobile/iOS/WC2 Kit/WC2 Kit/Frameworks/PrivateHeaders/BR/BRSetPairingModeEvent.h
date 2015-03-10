//
//  BRSetPairingModeEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_PAIRING_MODE_EVENT 0x0A24



@interface BRSetPairingModeEvent : BREvent

@property(nonatomic,readonly) BOOL enable;


@end
