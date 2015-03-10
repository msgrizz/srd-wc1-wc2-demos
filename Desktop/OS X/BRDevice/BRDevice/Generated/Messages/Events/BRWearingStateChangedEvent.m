//
//  BRWearingStateChangedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRWearingStateChangedEvent.h"
#import "BRMessage_Private.h"


@interface BRWearingStateChangedEvent ()

@property(nonatomic,assign,readwrite) BOOL worn;


@end


@implementation BRWearingStateChangedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_WEARING_STATE_CHANGED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"worn", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRWearingStateChangedEvent %p> worn=%@",
            self, (self.worn ? @"YES" : @"NO")];
}

@end
