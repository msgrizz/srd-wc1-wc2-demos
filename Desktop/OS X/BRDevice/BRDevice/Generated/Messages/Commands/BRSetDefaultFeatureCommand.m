//
//  BRSetDefaultFeatureCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetDefaultFeatureCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetDefaultFeatureCommand

#pragma mark - Public

+ (BRSetDefaultFeatureCommand *)command
{
	BRSetDefaultFeatureCommand *instance = [[BRSetDefaultFeatureCommand alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_DEFAULT_FEATURE;
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
    return [NSString stringWithFormat:@"<BRSetDefaultFeatureCommand %p>",
            self];
}

@end
