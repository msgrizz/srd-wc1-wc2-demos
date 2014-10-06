//
//  BRReceiveAudioStateEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRReceiveAudioStateEvent.h"
#import "BRMessage_Private.h"




@interface BRReceiveAudioStateEvent ()

@property(nonatomic,assign,readwrite) BOOL state;


@end


@implementation BRReceiveAudioStateEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_RECEIVE_AUDIO_STATE_EVENT;
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
    return [NSString stringWithFormat:@"<BRReceiveAudioStateEvent %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
