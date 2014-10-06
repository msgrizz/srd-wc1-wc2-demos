//
//  BRPartNumberEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_PART_NUMBER_EVENT 0x0A05



@interface BRPartNumberEvent : BREvent

@property(nonatomic,readonly) uint32_t partNumber;


@end
