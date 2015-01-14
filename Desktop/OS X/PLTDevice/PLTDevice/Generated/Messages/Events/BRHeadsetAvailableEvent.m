//
//  BRHeadsetAvailableEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHeadsetAvailableEvent.h"
#import "BRMessage_Private.h"


@interface BRHeadsetAvailableEvent ()

@property(nonatomic,assign,readwrite) BOOL state;


@end


@implementation BRHeadsetAvailableEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_HEADSET_AVAILABLE_EVENT;
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
    return [NSString stringWithFormat:@"<BRHeadsetAvailableEvent %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
