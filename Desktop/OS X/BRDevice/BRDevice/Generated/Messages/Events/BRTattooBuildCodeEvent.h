//
//  BRTattooBuildCodeEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_TATTOO_BUILD_CODE_EVENT 0x0A03



@interface BRTattooBuildCodeEvent : BREvent

@property(nonatomic,readonly) NSData * buildCode;


@end
