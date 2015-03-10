//
//  BRVocalystInfoNumberEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_VOCALYST_INFO_NUMBER_EVENT 0x0A16



@interface BRVocalystInfoNumberEvent : BREvent

@property(nonatomic,readonly) NSString * infoPhoneNumber;


@end
