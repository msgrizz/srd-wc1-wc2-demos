//
//  BRInvalidServiceIDsException.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRException.h"


#define BR_INVALID_SERVICE_IDS_EXCEPTION 0xFF90



@interface BRInvalidServiceIDsException : BRException

@property(nonatomic,readonly) NSData * ids;


@end
