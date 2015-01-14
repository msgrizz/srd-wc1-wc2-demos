//
//  BRTrainingHeadsetConnectionEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTrainingHeadsetConnectionEvent.h"
#import "BRMessage_Private.h"


@interface BRTrainingHeadsetConnectionEvent ()

@property(nonatomic,assign,readwrite) BOOL state;


@end


@implementation BRTrainingHeadsetConnectionEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TRAINING_HEADSET_CONNECTION_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"state", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTrainingHeadsetConnectionEvent %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
