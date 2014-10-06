//
//  BRUserIDEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_USER_ID_EVENT 0x0A06



@interface BRUserIDEvent : BREvent

@property(nonatomic,readonly) NSData * userID;


@end
