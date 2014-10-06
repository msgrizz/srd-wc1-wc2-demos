//
//  BRSetOneStringEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_ONE_STRING_EVENT 0x0055



@interface BRSetOneStringEvent : BREvent

@property(nonatomic,readonly) NSString * value;


@end
