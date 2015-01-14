//
//  BRTrainingHeadsetConnectionCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTrainingHeadsetConnectionCommand.h"
#import "BRMessage_Private.h"


@implementation BRTrainingHeadsetConnectionCommand

#pragma mark - Public

+ (BRTrainingHeadsetConnectionCommand *)command
{
	BRTrainingHeadsetConnectionCommand *instance = [[BRTrainingHeadsetConnectionCommand alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TRAINING_HEADSET_CONNECTION;
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
    return [NSString stringWithFormat:@"<BRTrainingHeadsetConnectionCommand %p>",
            self];
}

@end
