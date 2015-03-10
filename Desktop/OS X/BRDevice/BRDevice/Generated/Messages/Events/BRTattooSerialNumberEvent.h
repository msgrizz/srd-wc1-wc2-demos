//
//  BRTattooSerialNumberEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_TATTOO_SERIAL_NUMBER_EVENT 0x0A01



@interface BRTattooSerialNumberEvent : BREvent

@property(nonatomic,readonly) NSData * serialNumber;


@end
