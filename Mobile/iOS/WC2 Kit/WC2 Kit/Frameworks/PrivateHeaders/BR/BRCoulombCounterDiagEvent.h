//
//  BRCoulombCounterDiagEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_COULOMB_COUNTER_DIAG_EVENT 0x1114



@interface BRCoulombCounterDiagEvent : BREvent

@property(nonatomic,readonly) NSData * coulombCounterData;


@end
