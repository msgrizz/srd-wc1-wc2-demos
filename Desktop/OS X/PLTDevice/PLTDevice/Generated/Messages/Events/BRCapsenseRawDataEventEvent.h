//
//  BRCapsenseRawDataEventEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CAPSENSE_RAW_DATA_EVENT_EVENT 0x101A



@interface BRCapsenseRawDataEventEvent : BREvent

@property(nonatomic,readonly) NSData * capsenseRawData;


@end
