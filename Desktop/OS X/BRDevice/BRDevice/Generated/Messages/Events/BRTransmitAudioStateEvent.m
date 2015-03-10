//
//  BRTransmitAudioStateEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTransmitAudioStateEvent.h"
#import "BRMessage_Private.h"


@interface BRTransmitAudioStateEvent ()

@property(nonatomic,assign,readwrite) BOOL state;


@end


@implementation BRTransmitAudioStateEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TRANSMIT_AUDIO_STATE_EVENT;
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
    return [NSString stringWithFormat:@"<BRTransmitAudioStateEvent %p> state=%@",
            self, (self.state ? @"YES" : @"NO")];
}

@end
