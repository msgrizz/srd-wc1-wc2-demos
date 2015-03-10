//
//  BRInvalidServiceIDsException.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRException.h"


#define BR_INVALID_SERVICE_IDS_EXCEPTION 0xFF90



@interface BRInvalidServiceIDsException : BRException

@property(nonatomic,readonly) NSData * ids;


@end
