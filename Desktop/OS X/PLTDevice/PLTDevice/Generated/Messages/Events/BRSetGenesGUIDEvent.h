//
//  BRSetGenesGUIDEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_SET_GENES_GUID_EVENT 0x0A1E



@interface BRSetGenesGUIDEvent : BREvent

@property(nonatomic,readonly) NSData * guid;


@end
