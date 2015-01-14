//
//  BRSoftwareBatteryDiagEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SOFTWARE_BATTERY_DIAG_EVENT 0x1110



@interface BRSoftwareBatteryDiagEvent : BREvent

@property(nonatomic,readonly) NSData * softwareBatteryData;


@end
