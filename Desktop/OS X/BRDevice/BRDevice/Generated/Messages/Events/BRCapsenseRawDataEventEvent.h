//
//  BRCapsenseRawDataEventEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CAPSENSE_RAW_DATA_EVENT_EVENT 0x101A



@interface BRCapsenseRawDataEventEvent : BREvent

@property(nonatomic,readonly) NSData * capsenseRawData;


@end
