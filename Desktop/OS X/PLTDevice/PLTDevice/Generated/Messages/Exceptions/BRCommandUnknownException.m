//
//  BRCommandUnknownException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommandUnknownException.h"
#import "BRMessage_Private.h"




@interface BRCommandUnknownException ()



@end


@implementation BRCommandUnknownException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_COMMAND_UNKNOWN_EXCEPTION;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[

			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCommandUnknownException %p>",
            self];
}

@end
