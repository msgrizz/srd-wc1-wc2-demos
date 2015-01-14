//
//  BRInvalidServiceModesException.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRException.h"


#define BR_INVALID_SERVICE_MODES_EXCEPTION 0xFF92



@interface BRInvalidServiceModesException : BRException

@property(nonatomic,readonly) NSData * modes;


@end
