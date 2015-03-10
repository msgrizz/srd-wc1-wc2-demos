//
//  BRSetVocalystPhoneNumberEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_VOCALYST_PHONE_NUMBER_EVENT 0x0A12



@interface BRSetVocalystPhoneNumberEvent : BREvent

@property(nonatomic,readonly) NSString * vocalystPhoneNumber;


@end
