//
//  BRManufacturingTestMessageEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_MANUFACTURING_TEST_MESSAGE_EVENT 0x0805



@interface BRManufacturingTestMessageEvent : BREvent

@property(nonatomic,readonly) NSData * data;


@end
