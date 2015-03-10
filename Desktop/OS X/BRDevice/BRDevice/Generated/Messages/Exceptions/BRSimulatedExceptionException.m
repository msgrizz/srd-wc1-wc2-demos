//
//  BRSimulatedExceptionException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSimulatedExceptionException.h"
#import "BRMessage_Private.h"


@interface BRSimulatedExceptionException ()



@end


@implementation BRSimulatedExceptionException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SIMULATED_EXCEPTION_EXCEPTION;
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
    return [NSString stringWithFormat:@"<BRSimulatedExceptionException %p>",
            self];
}

@end
