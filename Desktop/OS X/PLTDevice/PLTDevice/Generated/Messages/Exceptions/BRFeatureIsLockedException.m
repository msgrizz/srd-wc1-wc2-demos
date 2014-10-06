//
//  BRFeatureIsLockedException.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRFeatureIsLockedException.h"
#import "BRMessage_Private.h"




@interface BRFeatureIsLockedException ()



@end


@implementation BRFeatureIsLockedException

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_FEATURE_IS_LOCKED_EXCEPTION;
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
    return [NSString stringWithFormat:@"<BRFeatureIsLockedException %p>",
            self];
}

@end
