//
//  BRTestInterfaceIsDisabledException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTestInterfaceIsDisabledException.h"
#import "BRMessage_Private.h"


@interface BRTestInterfaceIsDisabledException ()



@end


@implementation BRTestInterfaceIsDisabledException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TEST_INTERFACE_IS_DISABLED_EXCEPTION;
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
    return [NSString stringWithFormat:@"<BRTestInterfaceIsDisabledException %p>",
            self];
}

@end
